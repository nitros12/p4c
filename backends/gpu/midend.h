/*
Copyright 2019 Orange

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#ifndef _BACKENDS_GPU_MIDEND_H_
#define _BACKENDS_GPU_MIDEND_H_

#include "ir/ir.h"
#include "backends/ebpf/midend.h"
#include "backends/ebpf/ebpfOptions.h"

namespace GPU {

class MidEnd : public EBPF::MidEnd {


public:
    explicit MidEnd() : EBPF::MidEnd() {}
    const IR::ToplevelBlock* run(EbpfOptions& options, const IR::P4Program* program,
                                 std::ostream* outStream = nullptr);
};

} // namespace GPU

#endif //_BACKENDS_GPU_MIDEND_H_