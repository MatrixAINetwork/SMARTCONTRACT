/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.0;

contract ArithLib {

    uint constant internal P = 115792089237316195423570985008687907853269984665640564039457584007908834671663;
    uint constant internal N = 115792089237316195423570985008687907852837564279074904382605163141518161494337;
    uint constant internal M = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
    uint constant internal Gx = 55066263022277343669578718895168534326250603453777594175500187360389116729240;
    uint constant internal Gy = 32670510020758816978083085130507043184471273380659243275938904335757337482424;
    
    function ArithLib() { }

    function jdouble(uint _ax, uint _ay, uint _az) constant returns (uint, uint, uint) {

        if(_ay == 0) return (0, 0, 0);

        uint ysq = _ay * _ay;
        uint s = 4 * _ax * ysq;
        uint m = 3 * _ax * _ax;
        uint nx = m * m - 2 * s;
        uint ny = m * (s - nx) - 8 * ysq * ysq;
        uint nz = 2 * _ay * _az;
        return (nx, ny, nz);
    }

    function jadd(uint _ax, uint _ay, uint _az, uint _bx, uint _by, uint _bz) constant returns (uint, uint, uint) {

        if(_ay == 0) return (0, 0, 0);
        if(_ay == 0) return(_bx, _by, _bz);
        if(_by == 0) return(_ax, _ay, _az);

        uint u1 = _ax * _bz * _bz;
        uint u2 = _bx * _az * _az;
        uint s1 = _ay * _bz * _bz * _bz;
        uint s2 = _by * _az * _az * _az;

        if(u1 == u2) {
           if(s1 != s2) return(0, 0, 1);
           return jdouble(_ax, _ay, _az);
        }
        
        uint nx = (s2 - s1) * (s2 - s1) - (u2 - u1) * (u2 - u1) * (u2 - u1) - 2 * u1 * (u2 - u1) * (u2 - u1);

        return
            (nx,
             (s2 - s1) * (u1 * (u2 - u1) * (u2 - u1) - nx) - s1 * (u2 - u1) * (u2 - u1) * (u2 - u1),
             (u2 - u1) * _az * _bz);
    }

    function jmul(uint _bx, uint _by, uint _bz, uint _n) constant returns (uint, uint, uint) {

        _n = _n % N;
        if(((_bx == 0) && (_by == 0)) || (_n == 0)) return(0, 0, 1);

        uint ax;
        uint ay;
        uint az;
        (ax, ay, az) = (0, 0, 1);
        uint b = M;
        
        while(b > 0) {

           (ax, ay, az) = jdouble(ax, ay, az);
           if((_n & b) != 0) {
              
              if(ay == 0) {
                 (ax, ay, az) = (_bx, _by, _bz);
              } else {
                 (ax, ay, az) = jadd(ax, ay, az, _bx, _by, _bz);
              }
           }

           b = b / 2;
        }

        return (ax, ay, az);
    }
    
    function jexp(uint _b, uint _e, uint _m) constant returns (uint) {
        uint o = 1;
        uint bit = M;
        
        while (bit > 0) {
            uint bitval = 0;
            if(_e & bit > 0) bitval = 1;
            o = mulmod(mulmod(o, o, _m), _b ** bitval, _m);
            bitval = 0;
            if(_e & (bit / 2) > 0) bitval = 1;
            o = mulmod(mulmod(o, o, _m), _b ** bitval, _m);
            bitval = 0;
            if(_e & (bit / 4) > 0) bitval = 1;
            o = mulmod(mulmod(o, o, _m), _b ** bitval, _m);
            bitval = 0;
            if(_e & (bit / 8) > 0) bitval = 1;
            o = mulmod(mulmod(o, o, _m), _b ** bitval, _m);
            bit = (bit / 16);
        }
        return o;
    }
    
    function jrecover_y(uint _x, uint _y_bit) constant returns (uint) {

        uint xcubed = mulmod(mulmod(_x, _x, P), _x, P);
        uint beta = jexp(addmod(xcubed, 7, P), ((P + 1) / 4), P);
        uint y_is_positive = _y_bit ^ (beta % 2) ^ 1;
        return(beta * y_is_positive + (P - beta) * (1 - y_is_positive));
    }

    function jdecompose(uint _q0, uint _q1, uint _q2) constant returns (uint, uint) {
        uint ox = mulmod(_q0, jexp(_q2, P - 3, P), P);
        uint oy = mulmod(_q1, jexp(_q2, P - 4, P), P);
        return(ox, oy);
    }
    
    function isbit(uint _data, uint _bit) constant returns (uint) {
        return (_data / 2**(_bit % 8)) % 2;
    }

    function hash_pubkey_to_pubkey(uint _pub1, uint _pub2) constant returns (uint, uint) {
        uint x = uint(sha3(_pub1, _pub2));
        while(true) {
            uint xcubed = mulmod(mulmod(x, x, P), x, P);
            uint beta = jexp(addmod(xcubed, 7, P), ((P + 1) / 4), P);
            uint y = beta * (beta % 2) + (P - beta) * (1 - (beta % 2));
            if(addmod(xcubed, 7, P) == mulmod(y, y, P)) return(x, y);
            x = ((x + 1) % P);
        }
    }
    
    function () {
        throw;
    }
}