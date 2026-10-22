import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/home_timer_helper.dart';
import 'folder_app_icon.dart';

class FolderAddPresetAction {
  final String folderId;
  final String categoryFilter;
  const FolderAddPresetAction(this.folderId, this.categoryFilter);
}

class FolderModal extends StatefulWidget {
  final HomeFolderMeta folder;
  final List<HomeFolderItem> items;
  final bool isEditing;
  final Animation<double>? jiggleAnimation;
  final void Function(String folderId, String fromItemId, String toItemId) onReorderIcons;
  final void Function(String folderId, String itemId)? onUnpinItem;
  final VoidCallback onToggleEditing;

  const FolderModal({
    super.key,
    required this.folder,
    required this.items,
    required this.isEditing,
    this.jiggleAnimation,
    required this.onReorderIcons,
    this.onUnpinItem,
    required this.onToggleEditing,
  });

  static Future<Object?> show({
    required BuildContext context,
    required HomeFolderMeta folder,
    required List<HomeFolderItem> items,
    required bool isEditing,
    Animation<double>? jiggleAnimation,
    required void Function(String folderId, String fromItemId, String toItemId) onReorderIcons,
    void Function(String folderId, String itemId)? onUnpinItem,
    required VoidCallback onToggleEditing,
  }) {
    return showGeneralDialog<Object?>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'FolderModal',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 260),
      transitionBuilder: (context, anim, secondaryAnim, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 20 * anim.value,
            sigmaY: 20 * anim.value,
          ),
          child: FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.84, end: 1.0).animate(curved),
              child: child,
            ),
          ),
        );
      },
      pageBuilder: (ctx, anim, secondaryAnim) => FolderModal(
        folder: folder,
        items: items,
        isEditing: isEditing,
        jiggleAnimation: jiggleAnimation,
        onReorderIcons: onReorderIcons,
        onUnpinItem: onUnpinItem,
        onToggleEditing: onToggleEditing,
      ),
    );
  }

  @override
  State<FolderModal> createState() => _FolderModalState();
}

class _FolderModalState extends State<FolderModal>
    with SingleTickerProviderStateMixin {
  late List<HomeFolderItem> _currentItems;
  bool _isEditing = false;
  late AnimationController _jiggleController;
  late Animation<double> _jiggleAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.folder.id == 'stopwatch') {
      final defaultStopwatch = HomeTimerHelper.resolveFolderItem(
        folderId: 'stopwatch',
        itemId: 'stopwatch',
        routines: const [],
      );
      _currentItems = defaultStopwatch != null ? [defaultStopwatch] : List.from(widget.items);
    } else {
      _currentItems = List.from(widget.items);
    }
    _isEditing = widget.isEditing;

    _jiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
    );
    _jiggleAnimation = Tween<double>(begin: -2.4, end: 2.4).animate(
      CurvedAnimation(parent: _jiggleController, curve: Curves.easeInOutSine),
    );

    if (_isEditing) {
      _jiggleController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant FolderModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.folder.id == 'stopwatch') {
      final defaultStopwatch = HomeTimerHelper.resolveFolderItem(
        folderId: 'stopwatch',
        itemId: 'stopwatch',
        routines: const [],
      );
      _currentItems = defaultStopwatch != null ? [defaultStopwatch] : List.from(widget.items);
    } else {
      _currentItems = List.from(widget.items);
    }
  }

  @override
  void dispose() {
    _jiggleController.dispose();
    super.dispose();
  }

  void _toggleEditing([bool? enable]) {
    final next = enable ?? !_isEditing;
    if (_isEditing == next) return;
    setState(() {
      _isEditing = next;
    });
    if (_isEditing) {
      _jiggleController.repeat(reverse: true);
      HapticFeedback.mediumImpact();
    } else {
      _jiggleController.stop();
      _jiggleController.reset();
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = widget.folder.getTitle(l10n);
    final subtitle = widget.folder.getSubtitle(l10n);
    final badge = widget.folder.getBadge(l10n);

    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final safeVertical = screenHeight - padding.top - padding.bottom;
    final folderBoxWidth = (screenWidth - 44).clamp(300.0, 360.0);
    final folderBoxHeight = (safeVertical * 0.44).clamp(280.0, 390.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Dismiss folder or exit edit mode when tapping outside
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (_isEditing) {
                  _toggleEditing(false);
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Title and subtitle positioned outside above the folder container
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: widget.folder.color,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$badge • ${l10n?.itemsCount(_currentItems.length) ?? "${_currentItems.length} Items"}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_isEditing) ...[
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => _toggleEditing(false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E676),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  l10n?.done ?? 'Done',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Folder Container with NO close button
                      Container(
                        width: folderBoxWidth,
                        height: folderBoxHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF1E1E22),
                              widget.folder.color.withValues(alpha: 0.24),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(34),
                          border: Border.all(
                            color: widget.folder.color.withValues(alpha: 0.65),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.folder.color.withValues(alpha: 0.35),
                              blurRadius: 36,
                              offset: const Offset(0, 12),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.6),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        // Scrollable Folder Grid
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: ScrollConfiguration(
                            behavior: const ScrollBehavior().copyWith(scrollbars: false),
                            child: GridView.builder(
                              physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics(),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 10,
                                childAspectRatio: 0.74,
                              ),
                              itemCount: widget.folder.id == 'stopwatch'
                                  ? _currentItems.length
                                  : _currentItems.length + 1,
                              itemBuilder: (ctx, i) {
                                if (widget.folder.id != 'stopwatch') {
                                  // First slot is the "+" Add Timer / Custom Button
                                  if (i == 0) {
                                    return _buildAddPresetTile(context, l10n);
                                  }

                                  // Remaining slots are items in folder
                                  final itemIndex = i - 1;
                                  return _buildDraggableItem(context, _currentItems[itemIndex], itemIndex);
                                }

                                return _buildDraggableItem(context, _currentItems[i], i);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Top right layout edit icon (matching home page)
          Positioned(
            top: 0,
            right: 16,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _isEditing
                    ? TextButton.icon(
                        onPressed: () => _toggleEditing(false),
                        icon: const Icon(Icons.check_rounded, color: Color(0xFF00E676), size: 18),
                        label: Text(
                          l10n?.done ?? 'Done',
                          style: const TextStyle(
                            color: Color(0xFF00E676),
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      )
                    : Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1C),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white12),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.dashboard_customize_outlined,
                            color: Colors.white70,
                            size: 20,
                          ),
                          tooltip: l10n?.editFolder ?? (l10n?.editHomeScreen ?? 'Edit Folder'),
                          onPressed: () => _toggleEditing(true),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableItem(BuildContext context, HomeFolderItem item, int index) {
    return DragTarget<FolderItemDragData>(
      onWillAcceptWithDetails: (details) {
        return details.data.folderId == widget.folder.id && details.data.itemId != item.id;
      },
      onAcceptWithDetails: (details) async {
        final fromIdx = _currentItems.indexWhere((it) => it.id == details.data.itemId);
        final toIdx = _currentItems.indexWhere((it) => it.id == item.id);
        if (fromIdx != -1 && toIdx != -1 && fromIdx != toIdx) {
          setState(() {
            final moved = _currentItems.removeAt(fromIdx);
            _currentItems.insert(toIdx, moved);
          });
          final newIds = _currentItems.map((it) => it.id).toList();
          await HomeTimerHelper.saveFolderItems(widget.folder.id, newIds);
          widget.onReorderIcons(widget.folder.id, details.data.itemId, item.id);
          HapticFeedback.lightImpact();
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return LongPressDraggable<FolderItemDragData>(
          data: FolderItemDragData(folderId: widget.folder.id, itemId: item.id),
          delay: const Duration(milliseconds: 180),
          onDragStarted: () {
            if (!_isEditing) {
              _toggleEditing(true);
            }
            HapticFeedback.selectionClick();
          },
          feedback: FolderAppIcon(
            item: item,
            folderColor: widget.folder.color,
            isEditing: false,
            isFeedback: true,
            itemIndex: index,
          ),
          childWhenDragging: Opacity(
            opacity: 0.22,
            child: FolderAppIcon(
              item: item,
              folderColor: widget.folder.color,
              isEditing: false,
              itemIndex: index,
            ),
          ),
          child: AnimatedScale(
            scale: isHovered ? 1.10 : 1.0,
            duration: const Duration(milliseconds: 140),
            child: FolderAppIcon(
              item: item,
              folderColor: widget.folder.color,
              isEditing: _isEditing,
              jiggleAnimation: _jiggleAnimation,
              itemIndex: index,
              onTap: () {
                if (_isEditing) {
                  return;
                }
                Navigator.of(context).pop(item);
              },
              onLongPress: () => _toggleEditing(true),
              onRemove: (item.isPrimary || widget.folder.id == 'stopwatch')
                  ? null
                  : () async {
                      setState(() {
                        _currentItems.removeWhere((it) => it.id == item.id);
                      });
                      final newIds = _currentItems.map((it) => it.id).toList();
                      await HomeTimerHelper.saveFolderItems(widget.folder.id, newIds);
                      if (item.isPreset) {
                        widget.onUnpinItem?.call(widget.folder.id, item.id);
                      }
                      HapticFeedback.mediumImpact();
                    },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddPresetTile(BuildContext context, AppLocalizations? l10n) {
    return Tooltip(
      message: l10n?.addTimerOrCustomTooltip ?? 'Add Timer / Custom',
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop(
            FolderAddPresetAction(widget.folder.id, widget.folder.categoryFilter),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withValues(alpha: 0.05),
                border: Border.all(
                  color: widget.folder.color.withValues(alpha: 0.40),
                  style: BorderStyle.solid,
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.add_rounded,
                  size: 28,
                  color: widget.folder.color,
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 76,
              child: Text(
                l10n?.addTimerOrCustom ?? 'Add Timer /\nCustom',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.70),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
