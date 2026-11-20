#ifndef JRBiblePlaybackPolicy_h
#define JRBiblePlaybackPolicy_h
#include <stddef.h>
#include <stdbool.h>

enum { JRBibleStop = -1, JRBibleNextBook = -2, JRBiblePreviousBook = -3 };
/* Positive results are chapter indexes. Manual skipping ignores repeat and sleep modes. */
static inline long JRBibleNextChapter(size_t index, size_t count, int direction,
                                      bool automatic, int repeatMode, bool stopAtBookEnd) {
    if (!count || index >= count) return JRBibleStop;
    bool last = index + 1 == count;
    if (automatic && stopAtBookEnd && (repeatMode == 2 || last)) return JRBibleStop;
    if (automatic && repeatMode == 2) return (long)index;
    if (automatic && repeatMode == 1 && last) return 0;
    long next = (long)index + direction;
    if (next < 0) return JRBiblePreviousBook;
    if ((size_t)next >= count) return JRBibleNextBook;
    return next;
}
#endif
