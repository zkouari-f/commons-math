package org.apache.commons.math4.benchmarks;

import java.util.concurrent.TimeUnit;

import org.apache.commons.math4.transform.FastFourierTransform;
import org.apache.commons.numbers.complex.Complex;
import org.openjdk.jmh.annotations.Benchmark;
import org.openjdk.jmh.annotations.BenchmarkMode;
import org.openjdk.jmh.annotations.Fork;
import org.openjdk.jmh.annotations.Level;
import org.openjdk.jmh.annotations.Measurement;
import org.openjdk.jmh.annotations.Mode;
import org.openjdk.jmh.annotations.OutputTimeUnit;
import org.openjdk.jmh.annotations.Param;
import org.openjdk.jmh.annotations.Scope;
import org.openjdk.jmh.annotations.Setup;
import org.openjdk.jmh.annotations.State;
import org.openjdk.jmh.annotations.Warmup;

/**
 * Microbenchmarks for transforms.
 *
 * Notes:
 * - Sizes are powers of two (FFT requirement).
 * - Uses deterministic pseudo-random-ish input to keep results stable.
 */
@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.MICROSECONDS)
@Warmup(iterations = 3, time = 1, timeUnit = TimeUnit.SECONDS)
@Measurement(iterations = 3, time = 1, timeUnit = TimeUnit.SECONDS)
@Fork(value = 1)
@State(Scope.Thread)
public class FastFourierTransformBenchmark {

    @Param({"1024", "16384"})
    public int size;

    private FastFourierTransform fft;
    private Complex[] input;

    @Setup(Level.Trial)
    public void setup() {
        fft = new FastFourierTransform(FastFourierTransform.Norm.STD);
        input = new Complex[size];

        long x = 0x9E3779B97F4A7C15L; // fixed seed
        for (int i = 0; i < size; i++) {
            // SplitMix64-ish sequence (fast, deterministic)
            x += 0x9E3779B97F4A7C15L;
            long z = x;
            z = (z ^ (z >>> 30)) * 0xBF58476D1CE4E5B9L;
            z = (z ^ (z >>> 27)) * 0x94D049BB133111EBL;
            z = z ^ (z >>> 31);

            // Map to [-1, 1)
            double re = ((z & 0xFFFFFFFFL) / (double) 0x1_0000_0000L) * 2.0 - 1.0;
            double im = (((z >>> 32) & 0xFFFFFFFFL) / (double) 0x1_0000_0000L) * 2.0 - 1.0;
            input[i] = Complex.ofCartesian(re, im);
        }
    }

    @Benchmark
    public Complex[] fft_forward() {
        return fft.apply(input);
    }
}
