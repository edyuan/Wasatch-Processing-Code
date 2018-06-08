%define Legendre shift interval
start_pixel=1;  %a
end_pixel=bscan_pixel_height;  %b

%shift term: x on interval [-1,1] becomes (2x-a-b)/(b-a) on interval [a,b]
syms x
shift=(2*x-start_pixel-end_pixel)/(end_pixel-start_pixel);

%Legendre polynomials on interval [-1,1]
p0=1;
p1=x;
p2=0.5*(3*x^2-1);
p3=0.5*(5*x^3-3*x);
p4=0.125*(35*x^4-30*x^2+3);
p5=0.125*(63*x^5-70*x^3+15*x);
p6=(1/16)*(231*x^6-315*x^4+105*x^2-5);
p7=(1/16)*(429*x^7-693*x^5+315*x^3-35*x);

%Calculate shifted polynomials
%qi=pi(shift)
q0=1;
q1=subs(p1,x,shift);
q2=subs(p2,x,shift);
q3=subs(p3,x,shift);
q4=subs(p4,x,shift);
q5=subs(p5,x,shift);
q6=subs(p6,x,shift);
q7=subs(p7,x,shift);

%create vectors from qi over range [a,b]
range=start_pixel:end_pixel;

%These are the shifted orthagonal polynomials
%q0=1; this is the same
q1=subs(q1,x,range);
q2=subs(q2,x,range);
q3=subs(q3,x,range);
q4=subs(q4,x,range);
q5=subs(q5,x,range);
q6=subs(q6,x,range);
q7=subs(q7,x,range);

q1=double(q1);
q2=double(q2);
q3=double(q3);
q4=double(q4);
q5=double(q5);
q6=double(q6);
q7=double(q7);

