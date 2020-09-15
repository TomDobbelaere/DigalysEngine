import dengine_types
import dengine_utils
import dengine_memory
import tables

type
  DEngineRuntime* = ref object
    ## This is the VM itself, the runtime executes bytecode generated by the compiler
    memory: DEngineMemory
    ip: int32 ## Instruction pointer

proc init*(self: DEngineRuntime) =
  ## Initialize DEngineRuntime

  # Set up memory, fixed at 512 bytes large for now
  self.memory = DEngineMemory()
  self.memory.init(512)

proc load*(self: DEngineRuntime, program: seq[uint8]) =
  ## Load a program (DEN bytecode) into memory
  self.memory.put(0, program)
  self.ip = 0

proc op_addi(runtime: DEngineRuntime) =
  echo "ADDI"

proc execute(self: Opcode, runtime: DEngineRuntime) =
  ## Maps opcodes to procedures that handle them and executes it
  {
    Opcode.ADDI: op_addi
  }.toTable[self](runtime)

proc tick*(self: DEngineRuntime) =
  ## Grab the current instruction, interpret it as an opcode and execute it
  ((Opcode)self.memory.get(self.ip)).execute(self)
  self.ip += 1