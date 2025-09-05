function [alpha_deg, beta_deg] = AlphaBetaDegHistories(u, v, w, airspeed)
    alpha_deg = atand(w ./ u);
    beta_deg = asind(v ./ airspeed);
end