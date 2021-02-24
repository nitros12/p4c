#ifndef P4C_GPUMODEL_H
#define P4C_GPUMODEL_H

#include "frontends/common/model.h"
#include "frontends/p4/coreLibrary.h"
#include "ir/ir.h"
#include "lib/cstring.h"

namespace GPU {

    struct Pipeline_Model : public ::Model::Elem {
        Pipeline_Model() : Elem("Pipeline"),
                         parser("prs"), control("p"), deparser("dprs") {}

        ::Model::Elem parser;
        ::Model::Elem control;
        ::Model::Elem deparser;
    };

    class GPUModel : public ::Model::Model {
    protected:
        GPUModel() : Model("0.1"),
                      CPacketName("pkt"),
                      packet("packet", P4::P4CoreLibrary::instance.packetIn, 0),
                      pipeline() {}

    public:
        static GPUModel instance;
        static cstring reservedPrefix;

        ::Model::Elem CPacketName;
        ::Model::Param_Model packet;
        Pipeline_Model pipeline;

        static cstring reserved(cstring name) { return reservedPrefix + name; }

        int numberOfParserArguments() const { return 4; }
        int numberOfControlBlockArguments() const { return 3; }

        const IR::P4Program *run(const IR::P4Program *program) {
            if (program == nullptr)
                return nullptr;

            PassManager passes({
            });

            passes.setName("GPUFrontEnd");
            passes.setStopOnError(true);
            const IR::P4Program *result = program->apply(passes);
            return result;
        }
    };

}

#endif
