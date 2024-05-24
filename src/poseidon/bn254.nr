// Instantiations of Poseidon constants, permutations and sponge for prime field of the same order as BN254
mod perm;
mod consts;
mod optconsts;

use crate::poseidon::PoseidonOptConfig;
use dep::std;

#[field(bn254)]
fn Sigma<O>(x: [Field; O]) -> [Field; O] {
    let mut y = x;
    for i in 0..O {
        let t = y[i];
        let tt = t * t;
        let tttt = tt * tt;
        y[i] *= tttt;
    }
    y
}

#[field(bn254)]
pub fn permute<M, N, X, O>(pos_conf: PoseidonOptConfig<M, N, X>, mut state: [Field; O]) -> [Field; O] {
    let PoseidonOptConfig {t, rf, rp, alpha, C: C, Mat: M, PMat: P, S } = pos_conf;

    for i in 0..state.len() {
        state[i] += C[i];
    }

    for _r in 0..rf / 2 - 1 {
        state = Sigma(state);
        for i in 0..state.len() {
            state[i] = state[i] + C[state.len() * (_r + 1) as u64 + i as u64];
        }
        {
            let mut out = state;
            for i in 0..state.len() {
                let mut val = 0;
                for j in 0..state.len() {
                    val += state[j] * M[j][i];
                }
                out[i] = val;
            }
            state = out;
        }
    }

    state = Sigma(state);
    for i in 0..state.len() {
        state[i] = state[i] + C[state.len() * (rf / 2) as u64 + i as u64];
    }
    {
        let mut out = state;
        for i in 0..state.len() {
            let mut val = 0;
            for j in 0..state.len() {
                val += state[j] * P[j][i];
            }
            out[i] = val;
        }
        state = out;
    }

    for i in 0..state.len() {
        std::as_witness(state[i]);
    }

    for _r in 0..rp {
        state[0] = state[0].pow_32(alpha);
        state[0] += C[(rf/2 + 1) as u64 * state.len() as u64 + _r as u64];
        std::as_witness(state[0]);
        {
            let mut newState0 = 0;
            for j in 0..state.len() {
                let mul = S[(state.len() * 2 - 1) * _r as u64 + j as u64] * state[j];
                newState0 += mul;
            }
            for k in 1..state.len() {
                state[k] = state[k] + state[0] * S[(t * 2 - 1) as u64 * _r as u64 + state.len() + k - 1];
            }
            state[0] = newState0;

            if (_r & 1 == 0) {
                for k in 1..state.len() {
                    std::as_witness(state[k]);
                }
            }
        }
    }

    for _r in 0..rf / 2 - 1 {
        state = Sigma(state);
        for i in 0..state.len() {
            state[i] = state[i] + C[(rf/2+1) as u64 * (state.len()) as u64 + rp as u64 + _r as u64 *state.len() as u64 + i as u64];
        }
        {
            let mut out = state;
            for i in 0..state.len() {
                let mut val = 0;
                for j in 0..state.len() {
                    val += state[j] * M[j][i];
                }
                out[i] = val;
            }
            state = out;
        }
    }

    state = Sigma(state);
    {
        let mut out = state;
        for i in 0..state.len() {
            let mut val = 0;
            for j in 0..state.len() {
                val += state[j] * M[j][i];
            }
            out[i] = val;
        }
        state = out;
    }

    state
}

// Corresponding absorption.
#[field(bn254)]
fn absorb<M, N, X, O, P>(
    pos_conf: PoseidonOptConfig<M, N, X>,
    mut state: [Field; O], // Initial state; usually [0; O]
    rate: Field, // Rate
    capacity: Field, // Capacity; usually 1
    msg: [Field; P] // Arbitrary length message
) -> [Field; O] {
    assert(pos_conf.t == rate + capacity);

    let mut i = 0;

    for k in 0..msg.len() {
        // Add current block to state
        state[capacity + i] += msg[k];
        i = i+1;
        // Enough to absorb
        if i == rate {
            state = permute(pos_conf, state);
            i = 0;
        }
    }
    // If we have one more block to permute
    if i != 0 {
        state = permute(pos_conf, state);
    }

    state
}
// Variable-length Poseidon-128 sponge as suggested in second bullet point of §3 of https://eprint.iacr.org/2019/458.pdf
#[field(bn254)]
pub fn sponge<N>(msg: [Field; N]) -> Field {
    absorb(optconsts::x5_5_opt_config(), [0; 5], 4, 1, msg)[1]
}
// Various instances of the Poseidon hash function
// Consistent with Circom's implementation
pub fn hash_1(input: [Field; 1]) -> Field {
    let mut state = [0; 2];
    for i in 0..input.len() {
        state[i+1] = input[i];
    }

    perm::x5_2(state)[0]
}

pub fn hash_2(input: [Field; 2]) -> Field {
    let mut state = [0; 3];
    for i in 0..input.len() {
        state[i+1] = input[i];
    }

    perm::x5_3(state)[0]
}

pub fn hash_3(input: [Field; 3]) -> Field {
    let mut state = [0; 4];
    for i in 0..input.len() {
        state[i+1] = input[i];
    }

    perm::x5_4(state)[0]
}

pub fn hash_4(input: [Field; 4]) -> Field {
    let mut state = [0; 5];
    for i in 0..input.len() {
        state[i+1] = input[i];
    }

    perm::x5_5(state)[0]
}

pub fn hash_5(input: [Field; 5]) -> Field {
    let mut state = [0; 6];
    for i in 0..input.len() {
        state[i+1] = input[i];
    }

    perm::x5_6(state)[0]
}

pub fn hash_6(input: [Field; 6]) -> Field {
    let mut state = [0; 7];
    for i in 0..input.len() {
        state[i+1] = input[i];
    }

    perm::x5_7(state)[0]
}

pub fn hash_7(input: [Field; 7]) -> Field {
    let mut state = [0; 8];
    for i in 0..input.len() {
        state[i+1] = input[i];
    }

    perm::x5_8(state)[0]
}

pub fn hash_8(input: [Field; 8]) -> Field {
    let mut state = [0; 9];
    for i in 0..input.len() {
        state[i+1] = input[i];
    }

    perm::x5_9(state)[0]
}

pub fn hash_9(input: [Field; 9]) -> Field {
    let mut state = [0; 10];
    for i in 0..input.len() {
        state[i+1] = input[i];
    }

    perm::x5_10(state)[0]
}

pub fn hash_10(input: [Field; 10]) -> Field {
    let mut state = [0; 11];
    for i in 0..input.len() {
        state[i+1] = input[i];
    }

    perm::x5_11(state)[0]
}

pub fn hash_11(input: [Field; 11]) -> Field {
    let mut state = [0; 12];
    for i in 0..input.len() {
        state[i+1] = input[i];
    }

    perm::x5_12(state)[0]
}

pub fn hash_12(input: [Field; 12]) -> Field {
    let mut state = [0; 13];
    for i in 0..input.len() {
        state[i+1] = input[i];
    }

    perm::x5_13(state)[0]
}

pub fn hash_13(input: [Field; 13]) -> Field {
    let mut state = [0; 14];
    for i in 0..input.len() {
        state[i+1] = input[i];
    }

    perm::x5_14(state)[0]
}

pub fn hash_14(input: [Field; 14]) -> Field {
    let mut state = [0; 15];
    for i in 0..input.len() {
        state[i+1] = input[i];
    }

    perm::x5_15(state)[0]
}

pub fn hash_15(input: [Field; 15]) -> Field {
    let mut state = [0; 16];
    for i in 0..input.len() {
        state[i+1] = input[i];
    }

    perm::x5_16(state)[0]
}

pub fn hash_16(input: [Field; 16]) -> Field {
    let mut state = [0; 17];
    for i in 0..input.len() {
        state[i+1] = input[i];
    }

    perm::x5_17(state)[0]
}
