# Análisis de Conversión A/D — Raspberry Pi Pico 2W (RP2350)

Laboratorio de la asignatura **Comunicaciones Digitales**, Programa de Ingeniería en Telecomunicaciones, Universidad Militar Nueva Granada (UMNG).

Este repositorio contiene la captura, el procesamiento en MATLAB y el informe correspondientes a la práctica *"Exploración de conceptos de conversión Análogo–Digital (A/D)"*, realizada con una Raspberry Pi Pico 2W (RP2350) y su ADC de 12 bits.

## Descripción

El laboratorio se divide en dos partes:

- **Parte I — Muestreo:** observación experimental del proceso de muestreo del ADC (frecuencia de muestreo, número de muestras por período) usando un osciloscopio y `sampling_1.py`.
- **Parte II — Análisis estadístico:** captura de 10 000 muestras del ADC (`sampling_2.py`) para cinco niveles de tensión DC distintos, y procesamiento en MATLAB para calcular la media, la desviación estándar, comparar con la referencia del multímetro y analizar la relación entre el ruido observado y el tamaño ideal de 1 LSB.

## Contenido del repositorio

```
├── analisis_adc.m                  # Script MATLAB: procesamiento estadístico y gráficas
├── LAB1 C2/                        # Datos crudos capturados en la práctica
│   ├── samples_test_1.csv … 5.csv  # 10 000 lecturas Raw_u16 por ensayo
│   ├── histogram_test_1.csv … 5.csv
│   └── (capturas de osciloscopio y consola)
├── Informe_Laboratorio_ADC_RP2350.docx   # Informe final del laboratorio
└── README.md
```

## Requisitos

- MATLAB (probado en MATLAB Online) — no requiere toolboxes adicionales.
- Los archivos `samples_test_X.csv` deben estar dentro de la carpeta `LAB1 C2/`, en la misma ubicación que `analisis_adc.m`.

## Uso

1. Clonar el repositorio y abrir `analisis_adc.m` en MATLAB.
2. Ejecutar el script completo (`Run`).
3. El script:
   - Recupera el código nominal de 12 bits a partir de `Raw_u16` (`bitshift(raw16,-4)`).
   - Calcula la media y la desviación estándar de cada ensayo (`mean`, `std`).
   - Imprime en consola una tabla comparativa contra los valores reportados por `sampling_2.py`.
   - Genera tres figuras: lecturas *Vᵢ* vs. número de muestra, histograma en voltios e histograma de códigos de 12 bits.

## Resultados principales

- El ADC muestra buena **repetibilidad** (desviación estándar de 3,8–6,1 mV, equivalente a 4,7–7,6 LSB) pero un **error sistemático de offset** frente al multímetro (+9,7 a +25,6 mV en todos los ensayos).
- La dispersión medida supera ampliamente el ruido de cuantización teórico (LSB ideal ≈ 0,806 mV para VREF = 3,3 V), lo que indica que el ruido térmico/eléctrico domina sobre la cuantización.

## Autor

Juan Pablo Correa Niño — Ingeniería en Telecomunicaciones, UMNG.

## Referencias

- Universidad Militar Nueva Granada (2026). *Comunicaciones Digitales — Actividad de laboratorio: Exploración de conceptos de conversión A/D con Raspberry Pi Pico 2W.*
- Raspberry Pi Ltd. (2024). *RP2350 Datasheet* / *Raspberry Pi Pico 2 W Datasheet.*
- MicroPython Documentation. *machine.ADC — analog to digital conversion.*
