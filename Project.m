clear all
close all
clc 

%% 1.These inputs define the boundary conditions of Rankine Cycle
P1 = input('Enter Condenser Pressure (P1) in bar: '); 
P2 = input('Enter Boiler Pressure (P2) in bar: '); 
T3 = input('Enter Turbine Inlet Temperature (T3) in C: ');

if P1 < 0.00611
    error('Input Error: P1 cannot be lower than 0.00611 bar (Triple Point of water).');
end
if P2 <= P1
    error('Input Error: Boiler pressure (P2) must be higher than Condenser pressure (P1).');
end
Tsat_P2 = XSteam('Tsat_p', P2);
if T3 <= Tsat_P2
    error('Input Error: T3 (%.2f°C) must be higher than the Saturation Temp (%.2f°C) at P2 to avoid liquid in the turbine.', T3, Tsat_P2);
end
if P2 > 1000 || T3 > 2000
    error('Input Error: Values exceed XSteam library limits (1000 bar / 2000°C).');
end
fprintf('\nInputs Validated. Calculating Cycle.\n\n');
%% 2.State 1 (Condenser Exit / Pump Inlet)
T1 = XSteam('Tsat_p', P1);    
h1 = XSteam('hL_p', P1);  
s1 = XSteam('sL_p', P1); 
v1 = XSteam('vL_p', P1);

fprintf('At State 1:\n')
fprintf('P1= %f bar\n',P1)
fprintf('T1 = %f °C\n', T1)
fprintf('h1 = %f kJ/kg\n', h1)
fprintf('s1 = %f kJ/kgK\n', s1)
fprintf('v1 = %f m^3/kg\n\n', v1)

%% 3. State 2 (Pump Exit / Boiler Inlet)
s2 = s1;                       

h2 = XSteam('h_ps', P2, s2);   
T2 = XSteam('T_ps', P2, s2);
v2 = XSteam('v_ps', P2, s2);

fprintf('At State 2:\n')
fprintf('P2 = %f bar\n', P2)
fprintf('T2 = %f °C\n', T2)
fprintf('h2 = %f kJ/kg\n', h2)
fprintf('s2 = %f kJ/kgK\n', s2)
fprintf('v2 = %f m^3/kg\n\n', v2)

%% 4. State 3 (Turbine Inlet / Boiler Exit)
h3 = XSteam('h_pT', P2, T3);   
s3 = XSteam('s_pT', P2, T3);   
v3 = XSteam('v_pT', P2, T3);

fprintf('At State 3:\n')
fprintf('P3 = %f bar\n', P2)
fprintf('T3 = %f °C\n', T3)
fprintf('h3 = %f kJ/kg\n', h3)
fprintf('s3 = %f kJ/kgK\n', s3)
fprintf('v3 = %f m^3/kg\n\n', v3)

%% 5. State 4 (Turbine Exit/ Condenser Inlet)
s4= s3;

h4= XSteam('h_ps', P1, s4);
T4= XSteam('T_ps', P1, s4);
v4 = XSteam('v_ps', P1, s4);

fprintf('At state 4:\n')
fprintf('P4= %f bar\n', P1)
fprintf('T4= %f °C\n', T4)
fprintf('h4= %f kJ/kg\n', h4)
fprintf('s4= %f kJ/kgK\n', s4)
fprintf('v4 = %f m^3/kg\n\n', v4)

%% 6. Efficiency and Work Calculations
Wt = h3 - h4; 
Wp = h2 - h1;
Wnet = Wt - Wp;
Qin = h3 - h2;
Efficiency= (Wnet / Qin) * 100;

fprintf('Net Work Output: %f kJ/kg\n', Wnet)
fprintf('Thermal Efficiency: %.2f %%\n', Efficiency)

%% 7. Plotting the Saturation Dome
figure(1)
clf;
hold on
temp_range= linspace(0, 370 , 500);

for i = 1:length(temp_range)
    sL(i) = XSteam('sL_T', temp_range(i));
    sV(i)= XSteam('sV_T', temp_range(i));
end

tc= 373.95;
sc= 4.407;
S_dome= [sL, sc, fliplr(sV)];
T_dome= [temp_range, tc, fliplr(temp_range)];
plot(S_dome, T_dome, 'c--', 'LineWidth', 2)
xlabel('Entropy (s) [kJ/kg\cdotK]', 'Interpreter', 'tex', 'Color', 'w')
ylabel('Temperature (T) [^{\circ}C]', 'Interpreter', 'tex', 'Color', 'w')
title('Rankine Cycle T-s Diagram', 'Color', 'w')
grid on
set(gca, 'Color', 'k', 'XColor', 'w', 'YColor', 'w', 'GridColor', [0.5 0.5 0.5]);

%% 8. Plotting the cycle points
S_plot = [s1 s2 s3 s4 s1];
T_plot= [T1 T2 T3 T4 T1];

plot(S_plot, T_plot, 'y', 'LineWidth', 2.5) 
plot(S_plot, T_plot, 'ro', 'MarkerSize', 12, 'MarkerFaceColor', 'r');
text(s1 - 0.1, T1 - 10, ' 1', 'Color', 'w', 'FontWeight', 'bold', 'HorizontalAlignment', 'right');
text(s2 - 0.1, T2 + 10, ' 2', 'Color', 'w', 'FontWeight', 'bold', 'HorizontalAlignment', 'right');
text(s3 + 0.1, T3 + 10, ' 3', 'Color', 'w', 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
text(s4 + 0.1, T4 - 10, ' 4', 'Color', 'w', 'FontWeight', 'bold', 'HorizontalAlignment', 'left');

axis([0 10 0 450])

%% 9. Creating Subplots (Main + Zoom)
figure(2)
clf;
subplot(1,2,1)
hold on
plot(S_dome, T_dome, 'c--', 'LineWidth', 1.5) 
plot(S_plot, T_plot, 'y', 'LineWidth', 2)
plot(S_plot, T_plot, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r')
title('Full Rankine Cycle', 'Color', 'w')
set(gca, 'Color', 'k', 'XColor', 'w', 'YColor', 'w')
grid on
t_off_full = 10;
text(s1, T1 - t_off_full, ' 1', 'Color', 'w', 'VerticalAlignment', 'top', 'FontWeight', 'bold');
text(s2, T2 + t_off_full, ' 2', 'Color', 'w', 'VerticalAlignment', 'bottom', 'FontWeight', 'bold');
text(s3, T3 + t_off_full, ' 3', 'Color', 'w', 'VerticalAlignment', 'bottom', 'FontWeight', 'bold');
text(s4, T4 - t_off_full, ' 4', 'Color', 'w', 'VerticalAlignment', 'top', 'FontWeight', 'bold');

subplot(1,2,2)
hold on
plot(S_dome, T_dome, 'c--', 'LineWidth', 1.5) 
plot([s1 s2], [T1 T2], 'y', 'LineWidth', 3) 
plot([s1 s2], [T1 T2], 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r')
 
s_zoom = 0.005; 
t_buffer = 0.2;
axis([s1-s_zoom, s1+s_zoom, T1-t_buffer, T2+t_buffer])
title('Zoomed View: Pump Work (State 1 to 2)', 'Color', 'w')
set(gca, 'Color', 'k', 'XColor', 'w', 'YColor', 'w')
grid on
grid minor 
set(gca, 'GridAlpha', 0.2, 'MinorGridAlpha', 0.1);

label_offset_s = 0.0008; 
label_offset_t = 0.05;
text(s1 + label_offset_s, T1 - label_offset_t, ' 1', 'Color', 'w', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
text(s2 + label_offset_s, T2 + label_offset_t, ' 2', 'Color', 'w', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontWeight', 'bold');

%% 10. Plotting P-v Diagram
figure(3)
clf;
hold on
critical_pressure = 220.6;
p_range = linspace(P1, critical_pressure, 500);
for i = 1:length(p_range)
    vL_dome(i) = XSteam('vL_p', p_range(i));
    vV_dome(i) = XSteam('vV_p', p_range(i));
end
plot(vL_dome, p_range, 'c--', 'LineWidth', 1.5)
plot(vV_dome, p_range, 'c--', 'LineWidth', 1.5)

p_turbine = linspace(P2, P1, 100); 
for j = 1:length(p_turbine)
    v_turbine(j) = XSteam('v_ps', p_turbine(j), s3);
end

plot([v1 v2 v3], [P1 P2 P2], 'y', 'LineWidth', 2.5)
plot(v_turbine, p_turbine, 'y', 'LineWidth', 2.5)   
plot([v4 v1], [P1 P1], 'y', 'LineWidth', 2.5)      
plot([v1 v2 v3 v4], [P1 P2 P2 P1], 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r')
set(gca, 'XScale', 'log')
xlabel('Specific Volume (v) [m^3/kg]', 'Color', 'w')
ylabel('Pressure (P) [bar]', 'Color', 'w')
title('Rankine Cycle P-v Diagram', 'Color', 'w')
grid on
set(gca, 'GridAlpha', 0.3);

text(v1, P1-2, ' 1', 'Color', 'w', 'FontWeight', 'bold');
text(v2, P2+5, ' 2', 'Color', 'w', 'FontWeight', 'bold');
text(v3, P2+5, ' 3', 'Color', 'w', 'FontWeight', 'bold');
text(v4, P1-2, ' 4', 'Color', 'w', 'FontWeight', 'bold');