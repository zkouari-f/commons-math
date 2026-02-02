/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.commons.math4.transform;

import java.util.function.DoubleUnaryOperator;

import org.apache.commons.numbers.complex.Complex;

/**
 * Useful functions for the implementation of various transforms.
 * Class is package-private (for internal use only).
 */
final class TransformUtils {
    /** Number of array slots: 1 for "real" parts 1 for "imaginary" parts. */
    private static final int NUM_PARTS = 2;

    /** Utility class. */
    private TransformUtils() {}

    /**
     * Multiply every component in the given real array by the
     * given real number. The change is made in place.
     *
     * @param f Array to be scaled.
     * @param d Scaling coefficient.
     * @return a reference to the scaled array.
     */
        /*@ requires f != null;
            @ assignable f[*];
            @ ensures \result == f;
            @*/
    static double[] scaleInPlace(double[] f, double d) {
                int i = 0;
                /*@ loop_invariant 0 <= i && i <= f.length;
                    @ loop_assignable f[*], i;
                    @ decreases f.length - i;
                    @*/
                while (i < f.length) {
                        f[i] *= d;
                        i++;
                }
        return f;
    }

    /**
     * Multiply every component in the given complex array by the
     * given real number. The change is made in place.
     *
     * @param f Array to be scaled.
     * @param d Scaling coefficient.
     * @return the scaled array.
     */
        /*@ requires f != null;
            @ requires (\forall int j; 0 <= j && j < f.length; f[j] != null);
            @ ensures \result == f;
            @*/
    static Complex[] scaleInPlace(Complex[] f, double d) {
                int i = 0;
                /*@ loop_invariant 0 <= i && i <= f.length;
                    @ decreases f.length - i;
                    @*/
                while (i < f.length) {
                        f[i] = Complex.ofCartesian(d * f[i].getReal(), d * f[i].getImaginary());
                        i++;
                }
        return f;
    }


    /**
     * Builds a new two dimensional array of {@code double} filled with the real
     * and imaginary parts of the specified {@link Complex} numbers. In the
     * returned array {@code dataRI}, the data is laid out as follows
     * <ul>
     * <li>{@code dataRI[0][i] = dataC[i].getReal()},</li>
     * <li>{@code dataRI[1][i] = dataC[i].getImaginary()}.</li>
     * </ul>
     *
     * @param dataC Array of {@link Complex} data to be transformed.
     * @return a two dimensional array filled with the real and imaginary parts
     * of the specified complex input.
     */
        /*@ requires dataC != null;
            @ requires (\forall int j; 0 <= j && j < dataC.length; dataC[j] != null);
            @ ensures \result != null && \result.length == 2;
            @ ensures \result[0] != null && \result[0].length == dataC.length;
            @ ensures \result[1] != null && \result[1].length == dataC.length;
            @ ensures (\forall int j; 0 <= j && j < dataC.length;
            @            \result[0][j] == dataC[j].re &&
            @            \result[1][j] == dataC[j].im);
            @*/
    static double[][] createRealImaginary(final Complex[] dataC) {
        final double[][] dataRI = new double[2][dataC.length];
        final double[] dataR = dataRI[0];
        final double[] dataI = dataRI[1];
                int i = 0;
                /*@ loop_invariant 0 <= i && i <= dataC.length;
                    @ loop_invariant dataR != null && dataI != null;
                    @ loop_invariant dataR.length == dataC.length && dataI.length == dataC.length;
                    @ loop_invariant (\forall int j; 0 <= j && j < i; dataR[j] == dataC[j].re);
                    @ loop_invariant (\forall int j; 0 <= j && j < i; dataI[j] == dataC[j].im);
                    @ loop_assignable dataR[*], dataI[*], i;
                    @ decreases dataC.length - i;
                    @*/
                while (i < dataC.length) {
                        final Complex c = dataC[i];
                        dataR[i] = c.getReal();
                        dataI[i] = c.getImaginary();
                    /*@ assert dataR[i] == dataC[i].re; @*/
                    /*@ assert dataI[i] == dataC[i].im; @*/
                        i++;
                }
        return dataRI;
    }

    /**
     * Builds a new array of {@link Complex} from the specified two dimensional
     * array of real and imaginary parts. In the returned array {@code dataC},
     * the data is laid out as follows
     * <ul>
     * <li>{@code dataC[i].getReal() = dataRI[0][i]},</li>
     * <li>{@code dataC[i].getImaginary() = dataRI[1][i]}.</li>
     * </ul>
     *
     * @param dataRI Array of real and imaginary parts to be transformed.
     * @return a {@link Complex} array.
     * @throws IllegalArgumentException if the number of rows of the specified
     * array is not two, or the array is not rectangular.
     */
        /*@ requires dataRI != null;
            @ requires dataRI.length == 2;
            @ requires dataRI[0] != null && dataRI[1] != null;
            @ requires dataRI[0].length == dataRI[1].length;
            @ ensures \result != null;
            @ ensures \result.length == dataRI[0].length;
            @ ensures (\forall int j; 0 <= j && j < \result.length; \result[j] != null);
            @*/
    static Complex[] createComplex(final double[][] dataRI) {
        if (dataRI.length != NUM_PARTS) {
            throw new TransformException(TransformException.SIZE_MISMATCH,
                                         new Object[] { dataRI.length, NUM_PARTS });
        }
        final double[] dataR = dataRI[0];
        final double[] dataI = dataRI[1];
        if (dataR.length != dataI.length) {
            throw new TransformException(TransformException.SIZE_MISMATCH,
                                         new Object[] { dataI.length, dataR.length });
        }

        final int n = dataR.length;
        final Complex[] c = new Complex[n];
                int i = 0;
                /*@ loop_invariant 0 <= i && i <= n;
                    @ loop_invariant n == dataR.length && n == dataI.length;
                    @ loop_invariant c != null && c.length == n;
                    @ loop_invariant (\forall int j; 0 <= j && j < i; c[j] != null);
                    @ loop_assignable c[*], i;
                    @ decreases n - i;
                    @*/
                while (i < n) {
                        c[i] = Complex.ofCartesian(dataR[i], dataI[i]);
                        /*@ assert c[i] != null; @*/
                        i++;
                }
                /*@ assert i == n; @*/
                /*@ assert (\forall int j; 0 <= j && j < n; c[j] != null); @*/
        return c;
    }

    /**
     * Samples the specified univariate real function on the specified interval.
     * <p>
     * The interval is divided equally into {@code n} sections and sample points
     * are taken from {@code min} to {@code max - (max - min) / n}; therefore
     * {@code f} is not sampled at the upper bound {@code max}.</p>
     *
     * @param f Function to be sampled
     * @param min Lower bound of the interval (included).
     * @param max Upper bound of the interval (excluded).
     * @param n Number of sample points.
     * @return the array of samples.
     * @throws IllegalArgumentException if the lower bound {@code min} is
     * greater than, or equal to the upper bound {@code max}, if the number
     * of sample points {@code n} is negative.
     */
        /*@ requires f != null;
            @ requires n > 0;
            @ requires min < max;
            @ ensures \result != null;
            @ ensures \result.length == n;
            @*/
    static double[] sample(DoubleUnaryOperator f,
                           double min,
                           double max,
                           int n) {
        if (n <= 0) {
            throw new TransformException(TransformException.NOT_STRICTLY_POSITIVE,
                                         new Object[] { Integer.valueOf(n) });
        }
        if (min >= max) {
            throw new TransformException(TransformException.TOO_LARGE,
                                         new Object[] { Double.valueOf(min), Double.valueOf(max) });
        }

        final double[] s = new double[n];
        final double h = (max - min) / n;
                int i = 0;
                /*@ loop_invariant 0 <= i && i <= n;
                    @ loop_invariant s != null && s.length == n;
                    @ loop_assignable s[*], i;
                    @ decreases n - i;
                    @*/
                while (i < n) {
                        s[i] = f.applyAsDouble(min + i * h);
                        i++;
                }
        return s;
    }
}
