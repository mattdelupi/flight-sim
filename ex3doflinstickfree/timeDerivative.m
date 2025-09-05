function dydt = timeDerivative(time, y)

    function W = weightsDer(xs, xc, p)
        N = length(xs);
        xs = xs(:).';
        csi = xs - xc;
        M = zeros(N);
        I = eye(N);
    
        for j = 1:N
            M(j, :) = csi.^(j-1) ./ factorial(j-1);
        end
    
        W = M \ I;
        W = W.';
        W = W(p+1, :);
    end

    Nt = length(time);

    D = zeros(Nt);
    D(1, 1:3) = weightsDer(time(1:3), time(1), 1);
    for i = 2 : Nt-1
        stencil = time(i-1:i+1);
        D(i, i-1:i+1) = weightsDer(stencil, time(i), 1);
    end
    D(end, end-2:end) = weightsDer(time(end-2:end), time(end), 1);

    dydt = D * y;

end