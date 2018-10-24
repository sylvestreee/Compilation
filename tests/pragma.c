#pragma MPC precision(128) rounding(MPC_RNDZZ) {
    resultat =
        -(
            sqrt(-NMAX*(8*pc-4*pow(NMAX,3)-4*pow(NMAX,2)-NMAX-8))
            -2*pow(NMAX,2)-NMAX
        ) / (2*NMAX);
}
