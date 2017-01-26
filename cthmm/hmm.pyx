import numpy
import random
cimport numpy
cimport cython


ctypedef numpy.float64_t DTYPE_t

cdef class HMM:

    """Parameters _loga, _logb, _logpi are log likelihoods of _a, _b and _pi used to avoid underflow."""
    cdef numpy.ndarray _a #todo used only in generate, maybe can be erased.
    cdef numpy.ndarray _b #
    cdef numpy.ndarray _pi #
    cdef numpy.ndarray _loga
    cdef numpy.ndarray _logb
    cdef numpy.ndarray _logpi

    def __init__(self, A, B, Pi):
        """Initialize the HMM by small random values."""
        self._a = A
        self._b = B
        self._pi = Pi
        self._loga = numpy.log(A)
        self._logb = numpy.log(B)
        self._logpi = numpy.log(Pi)

    def generate(self, size ):
        """Randomly generate a sequence of states and emissions from model parameters."""
        states = numpy.zeros(size)
        emissions = numpy.zeros(size)
        current_state = numpy.random.choice( self._pi.shape[0], 1, p= self._pi)
        for i in range(size):
            states[i] = current_state
            emissions[i] =  numpy.random.choice( self._b.shape[1],1, p = self._b[ current_state,:].flatten() )
            current_state = numpy.random.choice( self._a.shape[1],1, p = self._a[ current_state,:].flatten() )
        return (states, emissions )

    #cpdef estimate(self, states, emissions):
    #    """From given state and emission sequence calculate their likelihood estimation given model parameters"""
    #

    #cpdef emission_estimate(self, emission ):
    #    """From given emission sequence calculate the likelihood estimation given model parameters"""
    #    return numpy.sum( self.backward( states,emission)[0,:] )

    #TODO log likelihood.
    cpdef forward(self, emissions):
        """From emission sequence calculate the forward variables (alpha) given model parameters.
           Return logaritmus of probabilities.
        """
        size = emissions.shape[0]
        states_num = self._a.shape[0]
        alpha = numpy.zeros( (size, states_num ))
        print(emissions[0])
        alpha[0,:] =  self._logpi + self._logb[:, int(emissions[0]) ]
        for i in range(1,size):
            for s in range(states_num):
                max_p = numpy.amax(  alpha[i-1,:] )                                                      #log-sum-exp trick
                log_sum = numpy.log ( numpy.sum( numpy.exp( alpha[i-1,:] + self._loga[:,s] - max_p ) ) ) #
                alpha[i,s] = max_p + log_sum

            alpha[i,:] = alpha[i,:] + self._logb[:, int(emissions[i]) ]

        return alpha

    cpdef viterbi(self, emissions):
        """From the emission sequence calculate most probable corresponding state sequence given parameters"""



    def from_file( self,file_path ):
        """Initialize the HMM by the file from the file_path storing the parameters A,B,Pi""" ##TODO define the file format.
        print("hello file")

    def _init__(self,num):
        print(num)

    def meow(self):
        """Make the HMM to meow"""
        print('meow!')


def main():
    #my_hmm = HMM()
    A = numpy.array([[0.9,0.1],[0.4,0.6]])
    B = numpy.array([[0.9,0.1],[0.2,0.8]])
    pi = numpy.array( [0.8,0.2] )
    hmm = HMM(A,B,pi)
    (s,e) = hmm.generate(3)
    print(s)
    print(e)

    print( numpy.exp(hmm.forward(e) ) )

    #hmm2 = HMM.from_parameters(A,B,pi)
    #hmm2 = HMM.from_file("x.hmm")
    #my_hmm.meow()

if __name__ == "__main__":
    main()
