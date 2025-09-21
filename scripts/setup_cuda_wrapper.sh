#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
WRAPPER_DIR="${ROOT_DIR}/build/cuda-wrapper"
CUDA_TOOLKIT_HOME_DEFAULT="/usr/local/cuda-13.0"
CUDA_TOOLKIT_HOME="${CUDA_TOOLKIT_HOME:-$CUDA_TOOLKIT_HOME_DEFAULT}"

mkdir -p "${WRAPPER_DIR}/bin"
cat > "${WRAPPER_DIR}/bin/nvcc" <<'NVCC'
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
exec "${CUDA_TOOLKIT_HOME}/bin/nvcc" "$@"
NVCC
chmod +x "${WRAPPER_DIR}/bin/nvcc"

ln -sfn "${CUDA_TOOLKIT_HOME}/include" "${WRAPPER_DIR}/include"
ln -sfn "${CUDA_TOOLKIT_HOME}/lib" "${WRAPPER_DIR}/lib"
ln -sfn "${CUDA_TOOLKIT_HOME}/lib64" "${WRAPPER_DIR}/lib64"

cat <<EOF_STAGE
Created CUDA wrapper at: ${WRAPPER_DIR}
Set these before building PufferLib from source:

  export CUDA_HOME=${WRAPPER_DIR}
  export FORCE_CUDA=1

Optionally set TORCH_CUDA_ARCH_LIST if you need specific SM targets.
EOF_STAGE
