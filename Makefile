include make_common

build_root = build

include_dirs = $(CUDA_HOME)/include $(MKL_ROOT)/include include/matrix include/net ./include
CXXFLAGS += $(addprefix -I,$(include_dirs))
NVCCFLAGS += $(addprefix -I,$(include_dirs))
NVCCFLAGS += -std=c++11 --use_fast_math

cu_files = $(shell $(FIND) src/ -name "*.cu" -printf "%P\n")
cpp_files = $(shell $(FIND) src/ -name "*.cpp" -printf "%P\n")
cu_obj_files = $(subst .cu,.o,$(cu_files))
cxx_obj_files = $(subst .cpp,.o,$(cpp_files))
obj_build_root = $(build_root)/objs
objs = $(addprefix $(obj_build_root)/cuda/,$(cu_obj_files)) $(addprefix $(obj_build_root)/cxx/,$(cxx_obj_files))
DEPS = ${objs:.o=.d}

lib_dir = $(build_root)/lib
net_lib = $(lib_dir)/libnet.a

all: $(net_lib) build/kernel_mean_field build/kernel_loopy_bp

$(net_lib): $(objs)
	$(dir_guard)
	ar rcs $@ $(objs)

$(obj_build_root)/cuda/%.o: src/%.cu
	$(dir_guard)
	$(NVCC) $(NVCCFLAGS) $(CUDA_ARCH) -M $< -o ${@:.o=.d} -odir $(@D)
	$(NVCC) $(NVCCFLAGS) $(CUDA_ARCH) -c $< -o $@
		
$(obj_build_root)/cxx/%.o: src/%.cpp
	$(dir_guard)
	$(CXX) $(CXXFLAGS) -MMD -c -o $@ $(filter %.cpp, $^)
	
build/%: src/%.cpp $(net_lib) ./include/*
	$(dir_guard)
	$(CXX) $(CXXFLAGS) -o $@ $(filter %.cpp, %.a $^) -L$(lib_dir) -lnet $(LDFLAGS)

clean:
	rm -rf build

-include $(DEPS)
