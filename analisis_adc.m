%% ========================================================================
%  Análisis estadístico de los datos del ADC — Punto 5 del Prelaboratorio
%  Comunicaciones Digitales — Raspberry Pi Pico 2W (RP2350)
%
%  Procesa samples_test_1.csv ... samples_test_5.csv (10 000 lecturas
%  Raw_u16 cada uno). Para cada ensayo:
%    a) Recupera el código nominal de 12 bits y calcula V, media y
%       desviación estándar.
%    b) Compara esos valores con los reportados en consola por
%       sampling_2.py.
%    c) Grafica las lecturas Vi vs. número de muestra.
%    d) Grafica el histograma de las mediciones en voltios.
%    e) Grafica el histograma de los códigos nominales de 12 bits.
% ========================================================================

clear; clc; close all;

%% --- Parámetros generales ---
VREF   = 3.3;              % Tensión de referencia del ADC [V]
Ntests = 5;

% Carpeta donde están los archivos samples_test_X.csv
% (ajustar si los archivos están en otra ubicación)
carpeta = "LAB1 C2";

% Valores de VDMM medidos con el multímetro para cada ensayo
VDMM = [0.500, 1.167, 1.656, 2.000, 2.946];

% Valores reportados directamente por sampling_2.py en consola
% (media y desviación estándar, para la comparación del punto b)
Vbar_reportado = [0.525560, 1.176656, 1.670595, 2.016595, 2.968678];
s_reportado_mV = [3.940,    3.797,    6.107,    5.505,    5.715];

%% --- Estructuras para almacenar resultados ---
Vbar_calc = zeros(1, Ntests);
s_calc_mV = zeros(1, Ntests);
Vmin      = zeros(1, Ntests);
Vmax      = zeros(1, Ntests);
datosV    = cell(1, Ntests);   % lecturas en voltios, por ensayo
datosCode = cell(1, Ntests);   % códigos nominales de 12 bits, por ensayo

%% --- Procesamiento de cada ensayo ---
for t = 1:Ntests
    archivo = fullfile(carpeta, sprintf("samples_test_%d.csv", t));

    T = readtable(archivo);        % columnas: Sample, Raw_u16
    raw16 = T.Raw_u16;

    % Recuperar el código nominal de 12 bits (Anexo 1):
    % raw16 = (code12 << 4) | (code12 >> 8)  =>  code12 = raw16 >> 4
    code12 = bitshift(raw16, -4);

    % Conversión a voltios: Vi ≈ (code12 / 4095) * VREF
    V = double(code12) / 4095 * VREF;

    % Estadísticos (std usa divisor N-1 por defecto en MATLAB)
    Vbar_calc(t) = mean(V);
    s_calc_mV(t) = std(V) * 1000;      % en mV
    Vmin(t)      = min(V);
    Vmax(t)      = max(V);

    datosV{t}    = V;
    datosCode{t} = code12;
end

%% --- a) y b) Tabla comparativa: sampling_2.py vs. recalculado en MATLAB ---
Test = (1:Ntests)';
Tcomp = table(Test, VDMM', Vbar_reportado', Vbar_calc', ...
              s_reportado_mV', s_calc_mV', ...
    'VariableNames', {'Test','VDMM_V','Vbar_sampling2py_V','Vbar_MATLAB_V', ...
                       's_sampling2py_mV','s_MATLAB_mV'});

disp('--- Comparación media y desviación estándar ---');
disp(Tcomp);

fprintf('\nDiferencia media  (MATLAB - sampling_2.py) [V] :\n');
disp(Vbar_calc - Vbar_reportado);
fprintf('Diferencia s      (MATLAB - sampling_2.py) [mV]:\n');
disp(s_calc_mV - s_reportado_mV);

%% --- c) Figura: lecturas Vi en función del número de muestra ---
figure('Name', 'Lecturas Vi vs numero de muestra', 'Position', [50 50 1000 900]);
for t = 1:Ntests
    subplot(3, 2, t);
    V = datosV{t};
    N = length(V);
    plot(0:N-1, V, 'Color', [0.17 0.42 0.69], 'LineWidth', 0.3);
    hold on;
    yline(Vbar_calc(t), '--', sprintf('Vbar=%.4f V', Vbar_calc(t)), ...
          'Color', 'r', 'LabelHorizontalAlignment', 'left');
    hold off;
    title(sprintf('Test %d — VDMM=%.3f V', t, VDMM(t)));
    xlabel('Número de muestra');
    ylabel('Voltaje [V]');
    grid on;
end
sgtitle('Lecturas del ADC V_i en función del número de muestra (N = 10000)');

%% --- d) Figura: histograma de las mediciones en voltios ---
figure('Name', 'Histograma en voltios', 'Position', [50 50 1000 900]);
for t = 1:Ntests
    subplot(3, 2, t);
    V = datosV{t};
    histogram(V, 40, 'FaceColor', [0.22 0.63 0.42], 'EdgeColor', 'white');
    hold on;
    xline(Vbar_calc(t), '--r', 'LineWidth', 1);
    hold off;
    title(sprintf('Test %d — Vbar=%.4f V, s=%.3f mV', t, Vbar_calc(t), s_calc_mV(t)));
    xlabel('Voltaje [V]');
    ylabel('Frecuencia');
    grid on;
end
sgtitle('Histograma de las mediciones expresadas en voltios');

%% --- e) Figura: histograma de los códigos nominales de 12 bits ---
figure('Name', 'Histograma de codigos de 12 bits', 'Position', [50 50 1000 900]);
for t = 1:Ntests
    subplot(3, 2, t);
    code12 = double(datosCode{t});
    edges = (min(code12)-0.5):1:(max(code12)+0.5);
    histogram(code12, edges, 'FaceColor', [0.50 0.35 0.83], 'EdgeColor', 'white');
    hold on;
    xline(mean(code12), '--r', 'LineWidth', 1);
    hold off;
    title(sprintf('Test %d — código medio=%.1f, rango=[%d,%d]', ...
          t, mean(code12), min(code12), max(code12)));
    xlabel('Código nominal de 12 bits');
    ylabel('Frecuencia');
    grid on;
end
sgtitle('Histograma de los códigos nominales de 12 bits del ADC');
