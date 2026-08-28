/// 串行化并合并草稿写入的协调器。
///
/// 解决两个问题：
///
/// 1. 并发写入乱序：`PhysicsLabDraftStorage.save` 的完成顺序不受接口保证，
///    较早快照可能晚于较新快照落盘并覆盖它。本协调器保证同一时刻最多一个
///    写入在途，从根上杜绝乱序完成。
/// 2. 写放大：快速连续编辑时只为“最新”状态落盘，写入期间到来的中间状态
///    被合并进下一轮写入，而不是每个 keystroke 各写一次。
///
/// 写入是尽力而为的：`_write` 抛出的异常被吞掉（失败的那次快照放弃，不会
/// 死循环重试），避免 fire-and-forget 产生未处理异步错误。
///
/// 同时充当“本地编辑版本号”来源：`load()` 可用 [editVersion] 判断恢复结果
/// 是否已因用户在加载期间的编辑而过期。
class DraftSaveCoordinator {
  DraftSaveCoordinator(this._write);

  /// 实际执行一次写入的函数。在真正写入时调用，应读取最新状态构建快照。
  final Future<void> Function() _write;

  int _editVersion = 0;
  int _writtenVersion = 0;
  bool _writing = false;

  /// 本地编辑版本号。每次 [markEdited] 自增一次。
  int get editVersion => _editVersion;

  /// 每次发生本地编辑后调用。
  void markEdited() {
    _editVersion += 1;
    _drain();
  }

  Future<void> _drain() async {
    if (_writing) {
      return;
    }
    _writing = true;
    try {
      while (_writtenVersion < _editVersion) {
        final int target = _editVersion;
        try {
          await _write();
          _writtenVersion = target;
        } catch (_) {
          // 草稿持久化尽力而为：放弃本次快照，避免失败时死循环重试。
          _writtenVersion = target;
        }
      }
    } finally {
      _writing = false;
    }
    // 写入期间可能又来了新编辑；那些编辑触发的 _drain 因 _writing 为 true
    // 被跳过，这里补一轮，确保最新状态最终落盘。
    if (_writtenVersion < _editVersion) {
      _drain();
    }
  }
}