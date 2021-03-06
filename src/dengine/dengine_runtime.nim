import dengine_types
import dengine_memory
import dengine_stack
import dengine_runtime_ops
import tables

type
  DEngineRuntime* = ref object
    ## This is the VM itself, the runtime executes bytecode generated by the compiler
    ##
    ## Note: The VM stack is implemented as a region in memory, starting from the end.
    memory*: DEngineMemory
    stack*: DEngineStack ## Operates directly on memory
    programSize: int ## Holds the length of the currently loaded program
    ip*: int32 ## Instruction pointer (starts at the beginning of memory)

# TODO: test
proc init*(self: DEngineRuntime, memSize: int = 512) =
  ## Initialize DEngineRuntime

  # Set up memory, fixed at 512 bytes large for now
  self.memory = DEngineMemory()
  self.memory.init(memSize)

  self.stack = DEngineStack()
  self.stack.init(self.memory)

# TODO: test
proc load*(self: DEngineRuntime, program: seq[uint8]) =
  ## Load a program (DEN bytecode) into memory
  self.memory.put(0, program)
  self.programSize = program.len
  self.ip = 0 # Start the instruction pointer at the beginning of memory

# TODO: test
proc reset*(self: DEngineRuntime) =
  self.ip = 0
  self.stack.reset()

proc execute(self: Opcode, runtime: DEngineRuntime) =
  ## Maps opcodes to procedures that handle them and executes it
  if self == Opcode.ADDI:
    op_add_int32(runtime.ip, runtime.memory, runtime.stack)
  elif self == Opcode.ADDF:
    op_add_float32(runtime.ip, runtime.memory, runtime.stack)
  elif self == Opcode.PSH:
    op_push(runtime.ip, runtime.memory, runtime.stack)
  elif self == Opcode.JMP:
    op_jump(runtime.ip, runtime.memory, runtime.stack)
  elif self == Opcode.DUP:
    op_duplicate(runtime.ip, runtime.memory, runtime.stack)
  elif self == Opcode.NOP:
    op_nop(runtime.ip, runtime.memory, runtime.stack)
  elif self == Opcode.OUT:
    op_out(runtime.ip, runtime.memory, runtime.stack)

# TODO: test
proc tick*(self: DEngineRuntime) =
  ## Grab the current instruction, interpret it as an opcode and execute it
  ((Opcode)self.memory.get(self.ip)).execute(self)

# TODO: test
proc run*(self: DEngineRuntime) =
  ## Run all code at once
  while self.ip < self.programSize:
    self.tick()
