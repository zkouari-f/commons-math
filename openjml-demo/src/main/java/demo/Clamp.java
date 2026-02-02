package demo;

/**
 * Tiny, self-contained OpenJML example that should verify cleanly.
 */
public final class Clamp {
    private Clamp() {
    }

    /*@ public normal_behavior
      @   requires lo <= hi;
      @   ensures lo <= \result && \result <= hi;
      @   ensures (x < lo) ==> (\result == lo);
      @   ensures (x > hi) ==> (\result == hi);
      @   ensures (lo <= x && x <= hi) ==> (\result == x);
      @*/
    public static int clamp(int x, int lo, int hi) {
        if (x < lo) {
            return lo;
        }
        if (x > hi) {
            return hi;
        }
        return x;
    }
}
