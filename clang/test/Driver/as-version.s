// Test version information.
// REQUIRES: integrated-as

// UNSUPPORTED: target={{.*}}-zos{{.*}}
// RUN: %clang -Wa,--version -c -fintegrated-as %s -o /dev/null \
// RUN:   | FileCheck --check-prefix=IAS %s
// IAS: clang version
