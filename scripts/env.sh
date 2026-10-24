# Source this file: `source scripts/env.sh`. Edit the paths to match your machine.
export STUDY=${STUDY:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}
export ACT=${ACT:-$HOME/work/riscv-arch-test}          # ACT4 checkout (branch act4)
export ACT_BASE=${ACT_BASE:-ac1923b}                    # ACT4 commit the study was done on
export SPIKE_ZFB=${SPIKE_ZFB:-$HOME/tools/spike-zfb-mut} # Spike with ZfbfminD mutants M1+M2
export SPIKE_DS4=${SPIKE_DS4:-$HOME/tools/spike-ds4}     # Spike with D S4 mutants (SPIKE_MUTANT=M1..M4)
export JOBS=${JOBS:-4}
