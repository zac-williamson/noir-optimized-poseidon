// Instantiations of Poseidon permutation for the prime field of the same order as BN254
/// use consts::x5_2_config;
// use bn254::permute;
// use test_poseidon::PoseidonConfig;

use crate::poseidon::bn254::permute;
use crate::poseidon::PoseidonConfig;
use crate::poseidon::bn254::optconsts;

#[field(bn254)]
pub fn x5_2(mut state: [Field; 2]) -> [Field; 2] {
    state = permute(
        optconsts::x5_2_opt_config(),
        state);

    state
}

#[field(bn254)]
pub fn x5_3(mut state: [Field; 3]) -> [Field; 3] {
    state = permute(
        optconsts::x5_3_opt_config(),
        state);

    state
}

#[field(bn254)]
pub fn x5_4(mut state: [Field; 4]) -> [Field; 4] {
    state = permute(
        optconsts::x5_4_opt_config(),
        state);

    state
}

#[field(bn254)]
pub fn x5_5(mut state: [Field; 5]) -> [Field; 5] {
    state = permute(
        optconsts::x5_5_opt_config(),
        state);

    state
}

#[field(bn254)]
pub fn x5_6(mut state: [Field; 6]) -> [Field; 6] {
    state = permute(
        optconsts::x5_6_opt_config(),
        state);

    state
}

#[field(bn254)]
pub fn x5_7(mut state: [Field; 7]) -> [Field; 7] {
    state = permute(
        optconsts::x5_7_opt_config(),
        state);

    state
}

#[field(bn254)]
pub fn x5_8(mut state: [Field; 8]) -> [Field; 8] {
    state = permute(
        optconsts::x5_8_opt_config(),
        state);

    state
}

#[field(bn254)]
pub fn x5_9(mut state: [Field; 9]) -> [Field; 9] {
    state = permute(
        optconsts::x5_9_opt_config(),
        state);

    state
}

#[field(bn254)]
pub fn x5_10(mut state: [Field; 10]) -> [Field; 10] {
    state = permute(
        optconsts::x5_10_opt_config(),
        state);

    state
}

#[field(bn254)]
pub fn x5_11(mut state: [Field; 11]) -> [Field; 11] {
    state = permute(
        optconsts::x5_11_opt_config(),
        state);

    state
}

#[field(bn254)]
pub fn x5_12(mut state: [Field; 12]) -> [Field; 12] {
    state = permute(
        optconsts::x5_12_opt_config(),
        state);

    state
}

#[field(bn254)]
pub fn x5_13(mut state: [Field; 13]) -> [Field; 13] {
    state = permute(
        optconsts::x5_13_opt_config(),
        state);

    state
}

#[field(bn254)]
pub fn x5_14(mut state: [Field; 14]) -> [Field; 14] {
    state = permute(
        optconsts::x5_14_opt_config(),
        state);

    state
}

#[field(bn254)]
pub fn x5_15(mut state: [Field; 15]) -> [Field; 15] {
    state = permute(
        optconsts::x5_15_opt_config(),
        state);

    state
}

#[field(bn254)]
pub fn x5_16(mut state: [Field; 16]) -> [Field; 16] {
    state = permute(
        optconsts::x5_16_opt_config(),
        state);

    state
}

#[field(bn254)]
pub fn x5_17(mut state: [Field; 17]) -> [Field; 17] {
    state = permute(
        optconsts::x5_17_opt_config(),
        state);

    state
}
