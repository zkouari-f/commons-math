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
