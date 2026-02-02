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
