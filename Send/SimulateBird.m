function simulation = SimulateBird(type, time, FS)
    if (nargin == 2) 
        FS = 8192; 
    end
    if (type < 1 || type > 8) 
        simulation = 0;
        return;
    end
    simulation = zeros(time * FS, 1);
    
    if (type == 1 || type == 2)
        if (type == 1)
            f = 0.2 + 0.01*randn;
            df = 0.001 + 0.0001*randn;
            phi = 2*pi*rand;
        elseif (type == 2)
            f = 0.2 + 0.01*randn;
            df = 0.0012 + 0.0001*randn;
            phi = 2*pi*rand;
        end
        
        for n = 1:length(simulation)
            simulation(n) = real(exp(2i*pi*(f*n + df*n*n/2) + phi));
        end
    elseif (type >= 3 && type <= 6)
        if (type == 3)
            k = 3;
            a = [3 + 0.005*randn, .5 + 0.005*randn, 2 + 0.05*randn];
            %f = [0.06 + 0.005*randn, 0.12 + 0.010*randn, 0.18 + 0.015*randn];
            f = [0.06 + 0.005*randn, 0, 0];
            f(2) = f(1)*2; f(3) = f(1)*3;
            phi = [2*pi*rand, 2*pi*rand, 2*pi*rand];
        elseif (type == 4)
            k = 2;
            a = [3 + 0.005*randn, 2 + 0.05*randn];
            %f = [0.06 + 0.005*randn, 0.18 + 0.015*randn];
            f = [0.06 + 0.005*randn, 0, 0];
            f(2) = f(1)*2;
            phi = [2*pi*rand, 2*pi*rand];
        elseif (type == 5)
            k = 2;
            a = [2 + 0.01*randn, 2 + 0.01*randn];
            f = [0.05 + 0.005*randn, 0.051 + 0.005*randn];
            phi = [2*pi*rand, 2*pi*rand];
        elseif (type == 6)
            k = 1;
            a = [4 + 0.01*randn];
            f = [0.0505 + 0.005*randn];
            phi = [2*pi*rand];
        end
        
        for n = 1:length(simulation)
            for kk = 1:k
                simulation(n) = simulation(n) + real(a(kk)*exp(2i*pi*f(kk)*n + phi(kk)));
            end
        end
    elseif (type == 7 || type == 8)
        
    end
    
end