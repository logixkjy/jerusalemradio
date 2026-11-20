#include "../jerusalemradio/Util/JRBiblePlaybackPolicy.h"
#include <assert.h>
#include <stdio.h>
int main(void) {
    /* Exercise every chapter, including Psalms, for all persisted repeat modes. */
    size_t counts[] = {1, 5, 22, 50, 150};
    for (size_t c = 0; c < sizeof(counts)/sizeof(counts[0]); c++) {
        size_t count = counts[c];
        for (size_t i = 0; i < count; i++) for (int mode = 0; mode < 3; mode++) {
            long sequential = i + 1 == count ? JRBibleNextBook : (long)i + 1;
            assert(JRBibleNextChapter(i,count,1,false,mode,true) == sequential);
            assert(JRBibleNextChapter(i,count,-1,false,mode,true) == (i == 0 ? JRBiblePreviousBook : (long)i - 1));
            long expected = mode == 2 ? (long)i : mode == 1 && i + 1 == count ? 0 : sequential;
            assert(JRBibleNextChapter(i,count,1,true,mode,false) == expected);
            long sleepExpected = mode == 2 || i + 1 == count ? JRBibleStop : (long)i + 1;
            assert(JRBibleNextChapter(i,count,1,true,mode,true) == sleepExpected);
        }
    }
    assert(JRBibleNextChapter(0,0,1,true,0,false) == JRBibleStop);
    assert(JRBibleNextChapter(50,50,1,true,0,false) == JRBibleStop);
    puts("PASS: chapter order, book boundaries, repeat modes, end-of-book sleep, manual skips");
}
