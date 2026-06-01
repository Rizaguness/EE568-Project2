% ============================================================
%  15-slot  10-pole FSCW PMSM  —  Analytical Design Script
%  EEE 568 Electric Machines  —  Project 2
%  Run with octave motor_design_calculations.m
% ============================================================


% ----------------------------------------------------------
% 0. GIVEN PARAMETERS
% ----------------------------------------------------------
Ns    = 15;          % number of stator slots
Nm    = 10;          % number of rotor poles
p     = Nm2;        % number of pole pairs
m     = 3;           % number of phases
Rso   = 50e-3;       % stator outer radius            [m]
Ls    = 100e-3;      % axial stack length             [m]
g     = 1e-3;        % physical air-gap length        [m]
lm    = 4e-3;        % radial magnet length           [m]
Br    = 1.3;         % magnet remanence               [T]
mu_rm = 1.05;        % magnet relative permeability   [-]
alp   = 160180;     % magnet pole-arc ratio          [-]
kwc   = 0.60;        % slot fill factor               [-]
J     = 5e6;         % conductor current density      [Am^2]
Bfe   = 1.4;         % target iron flux density       [T]
Vdc   = 48;          % DC bus voltage                 [V]
n_rpm = 1500;        % rated mechanical speed         [rpm]

% ----------------------------------------------------------
% 1. BASIC GEOMETRY
% ----------------------------------------------------------
fprintf('--- 1. Basic Geometry ---n');

Rro = 0.6  Rso;              % rotor outer radius     [m]
Rsi = Rro + g;                % stator inner radius    [m]
Dsi = 2Rsi;
Dro = 2Rro;
tau_s = 2piRsi  Ns;        % slot pitch at bore     [m]

fprintf('  Rro   = %6.2f mmn', Rro1e3);
fprintf('  Rsi   = %6.2f mmn', Rsi1e3);
fprintf('  Dsi   = %6.2f mmn', Dsi1e3);
fprintf('  Dro   = %6.2f mmn', Dro1e3);
fprintf('  tau_s = %6.4f mmnn', tau_s1e3);

% ----------------------------------------------------------
% 2. WINDING FACTORS
% ----------------------------------------------------------
fprintf('--- 2. Winding Factors ---nn');

% ---- 72s6p distributed winding (reference machine) ----
fprintf('  72-slot  6-pole double-layer windingn');
q72     = 4;                             % slots per pole per phase
al72    = 18012;                        % slot pitch [deg el.]
beta_fp = 180;                           % full pitch [deg el.]
beta_sp = (1112)180;                   % 1112 short pitch [deg el.]

kd72 = @(nu) sin(q72nual722  pi180) . (q72sin(nual722  pi180));
kp72_fp = @(nu) abs(sin(nubeta_fp2  pi180));
kp72_sp = @(nu) abs(sin(nubeta_sp2  pi180));

fprintf('  %-4s  %-8s  %-10s  %-10s  %-10s  %-10sn', ...
        'nu','kd','kp_full','kw_full','kp_1112','kw_1112');
for nu = [1 3 5]
    fprintf('  %-4d  %-8.4f  %-10.4f  %-10.4f  %-10.4f  %-10.4fn', ...
        nu, kd72(nu), kp72_fp(nu), kd72(nu)kp72_fp(nu), ...
        kp72_sp(nu), kd72(nu)kp72_sp(nu));
end
fprintf('n');

% ---- 15s10p FSCW ----
fprintf('  15-slot  10-pole FSCW (Nspp = 0.5)n');
beta_fscw = (1NmNs)180;              % coil pitch [deg el.] = 120 deg
kd_fscw   = 1;                          % single coil per pole belt - kd=1
kp_fscw   = @(nu) abs(sin(nubeta_fscw2  pi180));
kw_fscw   = @(nu) kd_fscw  kp_fscw(nu);
kw1       = kw_fscw(1);

fprintf('  beta_coil = %.1f deg el.n', beta_fscw);
fprintf('  %-4s  %-8s  %-8s  %-8sn', 'nu','kd','kp','kw');
for nu = [1 3 5]
    fprintf('  %-4d  %-8.4f  %-8.4f  %-8.4fn', ...
            nu, kd_fscw, kp_fscw(nu), kw_fscw(nu));
end
fprintf('n');

% ----------------------------------------------------------
% 3. AIR-GAP FLUX DENSITY  (iterative wtb depends on Bg)
% ----------------------------------------------------------
fprintf('--- 3. Air-Gap Flux Density (iterative) ---n');

Bg = 1.0;                               % initial estimate
for iter = 15
    wtb   = tau_s  Bg  Bfe;           % tooth body width       [m]
    bso   = tau_s - wtb;                % slot opening width     [m]
    gamma = bso^2  (5g + bso);        % Carter reduction       [m]
    kc    = tau_s  (tau_s - gamma);    % Carter coefficient     [-]
    Bg    = Br  (1 + mu_rmkcglm);  % peak air-gap Bg        [T]
end
g_eff = kc  (g + lmmu_rm);           % effective air gap      [m]

fprintf('  Converged after 5 iterationsn');
fprintf('  wtb   = %6.4f mmn', wtb1e3);
fprintf('  bso   = %6.4f mmn', bso1e3);
fprintf('  gamma = %6.4f mmn', gamma1e3);
fprintf('  kc    = %6.4fn',    kc);
fprintf('  g_eff = %6.4f mmn', g_eff1e3);
fprintf('  Bg    = %6.4f Tnn', Bg);

% ----------------------------------------------------------
% 4. SLOT GEOMETRY AND ELECTRICAL LOADING
% ----------------------------------------------------------
fprintf('--- 4. Slot Geometry and Electrical Loading ---n');

wsy  = 6e-3;                            % stator yoke thickness  [m]
hs   = (Rso - Rsi) - wsy;              % slot depth             [m]
As   = bso  hs;                        % slot area (rect. appr) [m^2]

nc_Iph = J  kwc  As;                 % amp-conductorsslot    [A]
A_lin  = (Ns  nc_Iph)  (pi  Dsi);  % electrical loading     [Am]

fprintf('  wsy    = %6.2f mmn', wsy1e3);
fprintf('  hs     = %6.2f mmn', hs1e3);
fprintf('  As     = %6.2f mm^2n', As1e6);
fprintf('  ncIph = %6.2f Aslotn', nc_Iph);
fprintf('  A_lin  = %6.0f Am  (%.2f Amm)nn', A_lin, A_lin1e-3);

% ----------------------------------------------------------
% 5. EFFECTIVE AXIAL LENGTH
% ----------------------------------------------------------
fprintf('--- 5. Effective Axial Length ---n');
Le = Ls + g;
fprintf('  Le = Ls + g = %.1f mmnn', Le1e3);

% ----------------------------------------------------------
% 6. FLUX PER POLE
% ----------------------------------------------------------
fprintf('--- 6. Flux Per Pole ---n');

Phi_p = Bg  alp  (piDroNm)  Le;

fprintf('  Phi_p = Bgalp(piDroNm)Len');
fprintf('        = %.4f  %.4f  %.6f  %.4fn', Bg, alp, piDroNm, Le);
fprintf('        = %.6f Wb  =  %.4f mWbnn', Phi_p, Phi_p1e3);

% Verify yoke sizing
wsy_check = Phi_p  (2LeBfe);
fprintf('  Yoke check wsy = Phi_p(2LeBfe) = %.2f mm  (design %.1f mm)nn', ...
        wsy_check1e3, wsy1e3);

% ----------------------------------------------------------
% 7. MAGNETIC LOADING, SHEAR STRESS, TORQUE
% ----------------------------------------------------------
fprintf('--- 7. Magnetic Loading, Shear Stress and Torque ---n');

B_avg  = Bg  alp;
sigma  = (kw1sqrt(2))  Bg  A_lin;
Tem    = sigma  2pi  Rro^2  Le;

% Cross-check
Tem_D2L = (pi2)  kw1  Bg  A_lin  alp  (Dsi^22)  Le;

fprintf('  B_avg  = Bg  alpha_p          = %.4f Tn', B_avg);
fprintf('  sigma  = (kw1sqrt2)BgA_lin  = %.2f Nm^2  =  %.3f kPan', ...
        sigma, sigma1e-3);
fprintf('  Tem    = sigma2piRro^2Le    = %.4f N.mn', Tem);
fprintf('  Tem    (D^2L cross-check)     = %.4f N.mnn', Tem_D2L);

% ----------------------------------------------------------
% 8. NUMBER OF TURNS PER PHASE
% ----------------------------------------------------------
fprintf('--- 8. Number of Turns per Phase ---n');

fe       = (n_rpm60)  p;              % electrical frequency   [Hz]
Eph_rms  = (Vdc2  sqrt(2))  0.90;   % target phase EMF rms   [V]

% EMF equation Eph = 4.44  fe  Nph  kw1  Phi_p
Nph_calc  = Eph_rms  (4.44  fe  kw1  Phi_p);
nc_calc   = Nph_calc  2  (Nsm);     % conductors per slot
nc_int    = ceil(nc_calc);             % round up to integer
Nph_int   = nc_int  (Nsm)  2;      % revised turns per phase
Eph_rev   = 4.44  fe  Nph_int  kw1  Phi_p;

fprintf('  fe         = %.1f Hzn', fe);
fprintf('  Eph_rms    = (Vdc2sqrt2)0.90 = %.2f Vn', Eph_rms);
fprintf('  Nph_calc   = Eph(4.44fekw1Phi_p) = %.2fn', Nph_calc);
fprintf('  nc_calc    = Nph_calc2(Nsm)  = %.2f  -  nc = %dn', ...
        nc_calc, nc_int);
fprintf('  Nph_int    = nc  (Nsm)  2   = %d turnsphasen', Nph_int);
fprintf('  Eph_rev    = 4.44feNph_intkw1Phi_p = %.2f Vnn', Eph_rev);

% ----------------------------------------------------------
% 9. SUMMARY TABLE
% ----------------------------------------------------------
fprintf('==========================================================n');
fprintf('  SUMMARYn');
fprintf('==========================================================n');
fprintf('  %-40s %9.4f  %sn','Rotor outer radius Rro',           Rro1e3,  'mm');
fprintf('  %-40s %9.4f  %sn','Stator inner radius Rsi',          Rsi1e3,  'mm');
fprintf('  %-40s %9.4f  %sn','Slot pitch at bore tau_s',         tau_s1e3,'mm');
fprintf('  %-40s %9.4f  %sn','Tooth body width wtb',             wtb1e3,  'mm');
fprintf('  %-40s %9.4f  %sn','Slot opening bso',                 bso1e3,  'mm');
fprintf('  %-40s %9.4f  %sn','Stator yoke thickness wsy',        wsy1e3,  'mm');
fprintf('  %-40s %9.4f  %sn','Slot depth hs',                    hs1e3,   'mm');
fprintf('  %-40s %9.2f  %sn','Slot area As',                     As1e6,   'mm^2');
fprintf('  %-40s %9.4f  %sn','Winding factor kw1',               kw1,      '');
fprintf('  %-40s %9.0f  %sn','Electrical loading A_lin',         A_lin,    'Am');
fprintf('  %-40s %9.4f  %sn','Carter coefficient kc',            kc,       '');
fprintf('  %-40s %9.4f  %sn','Effective air gap g_eff',          g_eff1e3,'mm');
fprintf('  %-40s %9.4f  %sn','Effective axial length Le',        Le1e3,   'mm');
fprintf('  %-40s %9.4f  %sn','Peak air-gap flux density Bg',     Bg,       'T');
fprintf('  %-40s %9.4f  %sn','Average flux density B_avg',       B_avg,    'T');
fprintf('  %-40s %9.6f  %sn','Flux per pole Phi_p',              Phi_p,    'Wb');
fprintf('  %-40s %9.2f  %sn','Rotor shear stress sigma',         sigma,    'Nm^2');
fprintf('  %-40s %9.4f  %sn','Electromagnetic torque Tem',       Tem,      'N.m');
fprintf('  %-40s %9.1f  %sn','Electrical frequency fe',          fe,       'Hz');
fprintf('  %-40s %9.2f  %sn','Target phase EMF Eph_rms',         Eph_rms,  'V');
fprintf('  %-40s %9d  %sn',  'Turns per phase Nph',              Nph_int,  '');
fprintf('  %-40s %9d  %sn',  'Conductors per slot nc',           nc_int,   '');
fprintf('  %-40s %9.2f  %sn','Revised back-EMF Eph_rev',         Eph_rev,  'V');
fprintf('==========================================================n');

