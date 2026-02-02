package demo;

/**
 * Tiny, self-contained example for OpenJML.
 *
 * Run (from repo root):
 *   powershell -ExecutionPolicy Bypass -File scripts/openjml.ps1
 */
public final class Factorial {
    private Factorial() {
    }

    /*@ public normal_behavior
      @   requires n >= 0 && n <= 12; // keep int factorial in range
      @   ensures \result >= 1;
      @   ensures (n == 0) ==> (\result == 1);
      @*/
    public static int factorial(int n) {
        int result = 1;
        int i = 1;
        /*@ loop_invariant 1 <= i && i <= n + 1;
          @ loop_invariant result >= 1;
          @ decreases n - i + 1;
          @*/
        while (i <= n) {
            result = result * i;
            i++;
        }
        return result;
    }
}
