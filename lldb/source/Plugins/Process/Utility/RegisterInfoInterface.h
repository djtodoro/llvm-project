//===-- RegisterInfoInterface.h --------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLDB_SOURCE_PLUGINS_PROCESS_UTILITY_REGISTERINFOINTERFACE_H
#define LLDB_SOURCE_PLUGINS_PROCESS_UTILITY_REGISTERINFOINTERFACE_H

#include "lldb/Utility/ArchSpec.h"
#include "lldb/lldb-private-types.h"
#include <vector>

namespace lldb_private {

/// \class RegisterInfoInterface
///
/// RegisterInfo interface to patch RegisterInfo structure for archs.
class RegisterInfoInterface {
public:
  RegisterInfoInterface(const lldb_private::ArchSpec &target_arch)
      : m_target_arch(target_arch) {}
  virtual ~RegisterInfoInterface() = default;

  virtual size_t GetGPRSize() const = 0;

  virtual const lldb_private::RegisterInfo *GetRegisterInfo() const = 0;

  // Returns the number of registers including the user registers and the
  // lldb internal registers also
  virtual uint32_t GetRegisterCount() const = 0;

  // Returns the number of the user registers (excluding the registers
  // kept for lldb internal use only). Subclasses should override it if
  // they belongs to an architecture with lldb internal registers.
  virtual uint32_t GetUserRegisterCount() const { return GetRegisterCount(); }

  // Returns the number of register sets for this architecture.
  // Subclasses should override if they provide register set information.
  virtual size_t GetRegisterSetCount() const { return 0; }

  // Returns the register set at the given index, or nullptr if not available.
  // Subclasses should override if they provide register set information.
  virtual const lldb_private::RegisterSet *GetRegisterSet(size_t set) const {
    return nullptr;
  }

  const lldb_private::ArchSpec &GetTargetArchitecture() const {
    return m_target_arch;
  }

private:
  lldb_private::ArchSpec m_target_arch;
};
} // namespace lldb_private

#endif
