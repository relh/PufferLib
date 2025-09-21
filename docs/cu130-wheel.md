# Building PufferLib 3.0.0 for CUDA 13.0 / sm_120

Metta relies on a custom CUDA build of the `compute_puff_advantage` kernel for
NVIDIA sm_120 hardware. Torch 2.8 currently publishes prebuilt wheels targeting
CUDA 12.x, so we ship a local wheel that is compiled against CUDA 13.0.

## Requirements

- CUDA Toolkit 13.0 installed at `/usr/local/cuda-13.0`
- PyTorch 2.8.x (compiled for CUDA 12.x)
- Python 3.11

Because PyTorch enforces a check between the detected CUDA compiler version and
the CUDA version used to build the Torch binaries, we wrap `nvcc` so it reports
`release 12.8` while still invoking the CUDA 13.0 compiler.

```bash
mkdir -p build/cuda13-wrapper/bin
cat > build/cuda13-wrapper/bin/nvcc <<'SH'
#!/usr/bin/env bash
if [[ "$1" == "--version" ]]; then
  cat <<'MSG'
nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2025 NVIDIA Corporation
Built on Wed_Aug_20_01:58:59_PM_PDT_2025
Cuda compilation tools, release 12.8, V12.8.0
Build cuda_12.8.r12.8/compiler.fake
MSG
  exit 0
fi
exec /usr/local/cuda-13.0/bin/nvcc "$@"
SH
chmod +x build/cuda13-wrapper/bin/nvcc

ln -sfn /usr/local/cuda-13.0/lib64 build/cuda13-wrapper/lib64
ln -sfn /usr/local/cuda-13.0/lib build/cuda13-wrapper/lib
ln -sfn /usr/local/cuda-13.0/include build/cuda13-wrapper/include
```

## Wheel build command

```bash
TORCH_CUDA_ARCH_LIST=12.0 \
FORCE_CUDA=1 \
CUDA_HOME=$(pwd)/build/cuda13-wrapper \
MAX_JOBS=$(nproc) \
python -m pip wheel . -w dist --no-build-isolation
```

The resulting wheel uses the version tag `3.0.0+cu130` and registers the
`compute_puff_advantage` kernel for sm_120 devices.

