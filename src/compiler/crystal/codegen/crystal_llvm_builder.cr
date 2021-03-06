module Crystal
  class CrystalLLVMBuilder
    property end : Bool

    def initialize(@builder : LLVM::Builder, @llvm_typer : LLVMTyper, @printf : LLVM::Function)
      @end = false
    end

    def llvm_nil
      @llvm_typer.nil_value
    end

    def ret
      return llvm_nil if @end
      value = @builder.ret
      @end = true
      value
    end

    def ret(value)
      return llvm_nil if @end
      value = @builder.ret(value)
      @end = true
      value
    end

    def br(block)
      return llvm_nil if @end
      value = @builder.br(block)
      @end = true
      value
    end

    def unreachable
      return if @end
      value = @builder.unreachable
      @end = true
      value
    end

    def printf(format, args = [] of LLVM::Value, catch_pad = nil)
      if catch_pad
        funclet = build_operand_bundle_def("funclet", [catch_pad])
      else
        funclet = LLVM::OperandBundleDef.null
      end

      call @printf, [global_string_pointer(format)] + args, bundle: funclet
    end

    def position_at_end(block)
      @builder.position_at_end block
      @end = false
    end

    def insert_block
      @builder.insert_block
    end

    def build_operand_bundle_def(name, values : Array(LLVM::Value))
      @builder.build_operand_bundle_def(name, values)
    end

    def to_unsafe
      @builder.to_unsafe
    end

    macro method_missing(call)
      return llvm_nil if @end

      @builder.{{call}}
    end
  end
end
