// mod bn254; // Instantiations of Poseidon for prime field of the same order as BN254
use dep::std::field::modulus_num_bits;
use dep::std::hash::Hasher;
use dep::std::default::Default;

mod bn254;

struct PoseidonOptConfig<M, N, X> { 
    t: Field, // Width, i.e. state size
    rf: u8, // Number of full rounds; should be even
    rp: u8, // Number of partial rounds
    alpha: Field, // S-box power; depends on the underlying field
    C: [Field; N],
    Mat: [[Field;M]; M], // Additive round keys
    PMat: [[Field;M]; M],
    S: [Field; X],
}

pub fn opt_config<M, N, X>(
    t: Field,
    rf: u8,
    rp: u8,
    alpha: Field,
    C: [Field; N],
    Mat: [[Field; M]; M],
    PMat: [[Field; M]; M],
    S: [Field; X]
) -> PoseidonOptConfig<M,N, X> {
    // Input checks

    PoseidonOptConfig { t, rf, rp, alpha, C, Mat, PMat, S }
}

struct PoseidonConfig<M,N> {
    t: Field, // Width, i.e. state size
    rf: u8, // Number of full rounds; should be even
    rp: u8, // Number of partial rounds
    alpha: Field, // S-box power; depends on the underlying field
    ark: [Field; M], // Additive round keys
    mds: [Field; N] // MDS Matrix in row-major order
}

pub fn config<M, N>(
    t: Field,
    rf: u8,
    rp: u8,
    alpha: Field,
    ark: [Field; M],
    mds: [Field; N]
) -> PoseidonConfig<M,N> {
    // Input checks
    let mul = dep::std::wrapping_mul(t as u8, (rf + rp));
    assert(mul == ark.len() as u8);
    assert(t * t == mds.len() as Field);
    assert(alpha != 0);

    PoseidonConfig { t, rf, rp, alpha, ark, mds }
}
// General Poseidon permutation on elements of type Field
fn permute<M, N, O>(pos_conf: PoseidonConfig<M, N>, mut state: [Field; O]) -> [Field; O] {
    let PoseidonConfig {t, rf, rp, alpha, ark, mds} = pos_conf;

    assert(t == state.len() as Field);

    let mut count = 0;
    // for r in 0..rf + rp
    for r in 0..(ark.len() / state.len()) {
        for i in 0..state.len() {
            state[i] = state[i] + ark[count + i];
        } // Shift by round constants
        state[0] = state[0].pow_32(alpha);
        // Check whether we are in a full round
        if (r as u8 < rf / 2) | (r as u8 >= rf / 2 + rp) {
            for i in 1..state.len() {
                state[i] = state[i].pow_32(alpha);
            }
        }
        state = apply_matrix(mds, state); // Apply MDS matrix
        count = count + t as u64;
    }

    state
}

// Absorption. Fully absorbs input message.
fn absorb<M, N, O, P>(
    pos_conf: PoseidonConfig<M, N>,
    mut state: [Field; O], // Initial state; usually [0; O]
    rate: Field, // Rate
    capacity: Field, // Capacity; usually 1
    msg: [Field; P]
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
// Check security of sponge instantiation
fn check_security(rate: Field, width: Field, security: Field) -> bool {
    let n = modulus_num_bits();

    ((n - 1) as Field * (width - rate) / 2) as u8 > security as u8
}
// A*x where A is an n x n matrix in row-major order and x an n-vector
fn apply_matrix<N, M>(a: [Field; M], x: [Field; N]) -> [Field; N] {
    let mut y = x;

    for i in 0..x.len() {
        y[i] = 0;
        for j in 0..x.len() {
            y[i] = y[i] + a[x.len()*i + j]* x[j];
        }
    }

    y
}

struct PoseidonHasher{
    _state: [Field],
}
impl Hasher for PoseidonHasher {
    #[field(bn254)]
    fn finish(self) -> Field {
        let mut result = 0;
        let len = self._state.len();
        assert(len < 16);
        if len == 1 {
            result = bn254::hash_1([self._state[0]]);
        } 
        if len == 2 {
            result = bn254::hash_2([self._state[0],self._state[1]]);
        } 
        if len == 3 {
            result = bn254::hash_3([self._state[0],self._state[1],self._state[2]]);
        } 
        if len == 4 {
            result = bn254::hash_4([self._state[0],self._state[1],self._state[2],self._state[3]]);
        } 
        if len == 5 {
            result = bn254::hash_5([self._state[0],self._state[1],self._state[2],self._state[3],self._state[4]]);
        }
        if len == 6 {
            result = bn254::hash_6([self._state[0],self._state[1],self._state[2],self._state[3],self._state[4], self._state[5]]);
        }
        if len == 7 {
            result = bn254::hash_7([self._state[0],self._state[1],self._state[2],self._state[3],self._state[4], self._state[5], self._state[6]]);
        }
        if len == 8 {
            result = bn254::hash_8([self._state[0],self._state[1],self._state[2],self._state[3],self._state[4], self._state[5], self._state[6], self._state[7]]);
        }
        if len == 9 {
            result = bn254::hash_9([self._state[0],self._state[1],self._state[2],self._state[3],self._state[4], self._state[5], self._state[6], self._state[7], self._state[8]]);
        }
        if len == 10 {
            result = bn254::hash_10([self._state[0],self._state[1],self._state[2],self._state[3],self._state[4], self._state[5], self._state[6], self._state[7], self._state[8], self._state[9]]);
        }
        if len == 11 {
            result = bn254::hash_11([self._state[0],self._state[1],self._state[2],self._state[3],self._state[4], self._state[5], self._state[6], self._state[7], self._state[8], self._state[9], self._state[10]]);
        }
        if len == 12 {
            result = bn254::hash_12([self._state[0],self._state[1],self._state[2],self._state[3],self._state[4], self._state[5], self._state[6], self._state[7], self._state[8], self._state[9], self._state[10], self._state[11]]);
        }
        if len == 13 {
            result = bn254::hash_13([self._state[0],self._state[1],self._state[2],self._state[3],self._state[4], self._state[5], self._state[6], self._state[7], self._state[8], self._state[9], self._state[10], self._state[11], self._state[12]]);
        }
        if len == 14 {
            result = bn254::hash_14([self._state[0],self._state[1],self._state[2],self._state[3],self._state[4], self._state[5], self._state[6], self._state[7], self._state[8], self._state[9], self._state[10], self._state[11], self._state[12], self._state[13]]);
        }
        if len == 15 {
            result = bn254::hash_15([self._state[0],self._state[1],self._state[2],self._state[3],self._state[4], self._state[5], self._state[6], self._state[7], self._state[8], self._state[9], self._state[10], self._state[11], self._state[12], self._state[13], self._state[14]]);
        }
        
        result
    }

    fn write(&mut self, input: Field){
        self._state = self._state.push_back(input);
    }

}

impl Default for PoseidonHasher{
    fn default() -> Self{
        PoseidonHasher{
            _state: [],
        }
    }
}
