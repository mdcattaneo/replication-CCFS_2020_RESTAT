
function [Rbart, betat, zbart, Nt, ehatit, e2hatt, e2hatt1, e2hatt2, e2t, Rbart_gridpts, muPrime_evalpts, evalport, Rbart_gridptsAlt] ...
                            = ccfsEst(Rt,zt,xt,wt,et,bins,gridpts,bkpoints,derivevalpoints,IdxLocalLzt,IdxLocalHzt)
                        
% CCFS_EST Summary of this function goes here
    if strcmp(bkpoints, 'quantiles')
        % Find cut-off points
        quant_z = quantile(zt,(1:1:(bins-1))/bins);
    else
        quant_z = bkpoints;
    end
    % Assign bin number to regressor
    [~, zt_ind] = histc(zt,[-Inf, quant_z, Inf]);
    % Count number of assets in each bin
    Nt = accumarray(zt_ind, ones(size(Rt)));
    
    % Calculate weights
    if ~isempty(wt)
        wbart = accumarray(zt_ind, wt); 
        WtVec = (wt./wbart(zt_ind));
    end    
    % Estimate function when there are no controls    
    if isempty(xt)
        betat = [];
        if ~isempty(wt),            
            Rbart = accumarray(zt_ind, Rt.*WtVec);
            % Assign bin average to each asset depending on which bin it is in
            Rt_hat = Rbart(zt_ind);        
        else        
            Rbart = accumarray(zt_ind, Rt)./Nt;
            % Assign bin average to each asset depending on which bin it is in
            Rt_hat = Rbart(zt_ind);        
        end
    else
        %if (bins> 10), keyboard; end
        nt = sum(Nt);
        BX = [(sparse((1:nt)',zt_ind,ones(nt,1))), xt];        
        if ~isempty(wt)
            Wt = sparse(diag(WtVec));
            gammabetat = (BX'*Wt*BX)\BX'*Wt*Rt;
        else
            gammabetat = (BX'*BX)\BX'*Rt;
        end
        Rbart = gammabetat(1:numel(Nt));
        gammabetat(1:numel(Nt)) = [];
        betat = gammabetat;
        %
        RtPurgext = Rbart(zt_ind);
        Rt_hat = Rbart(zt_ind) + xt*betat;
    end
    % Find average z in each bin
    zbart = accumarray(zt_ind, zt.*WtVec);   
    % Calculate errors
    ehatit = Rt-Rt_hat;    
%     ehatit1 = ehatit./sqrt(1-full(diag(P)));
%     ehatit2 = ehatit./(1-full(diag(P)));    
    % Calculate sum of squared errors in each bin
    if ~isempty(et), e2t = accumarray(zt_ind, et.^2); else e2t = []; end    
    e2hatt  = accumarray(zt_ind, ehatit.^2);
%     e2hatt1 = accumarray(zt_ind, ehatit1.^2);
%     e2hatt2 = accumarray(zt_ind, ehatit2.^2);
    e2hatt1 = [];
    e2hatt2 = [];
    % Calculate estimated mu at gridpts
    Rbart_gridpts = [];
    Rbart_gridptsAlt = NaN;
    if ~isempty(gridpts)
        [~, zt_ind_gridpts] = histc(gridpts,[-Inf, quant_z, Inf]);
        Rbart_gridpts = Rbart(zt_ind_gridpts);        
        if ~isempty(xt)
            if isempty(wt)
                Rbart_Alt = accumarray(zt_ind, Rt)./Nt;
            elseif ~isempty(wt)
                Rbart_Alt = accumarray(zt_ind, Rt.*WtVec);
            end
            Rbart_gridptsAlt = Rbart_Alt(zt_ind_gridpts);
        end
    end 
    muPrime_evalpts = [];
    evalport = [];    
    % Estimate mu'()    
    if ~isempty(derivevalpoints)
        if ~isempty(xt)
            RtDeriv = RtPurgext;            
        else
            RtDeriv = Rt;
        end        
        % Left-Hand Side
        [~, evalLport] = histc(derivevalpoints(1),[-Inf, quant_z, Inf]);
        % Right-Hand Side        
        [~, evalRport] = histc(derivevalpoints(2),[-Inf, quant_z, Inf]);
        evalport(1) = evalLport;
        evalport(2) = evalRport;
        %
        muPrime_evalpts = NaN(1,4);
        % First (Nearest neighbor)
        LocalWt = sqrt(WtVec(IdxLocalLzt));
        LocalRt = LocalWt.*RtDeriv(IdxLocalLzt);
        Localzt = repmat(LocalWt,[1,2]).*[ones(numel(IdxLocalLzt),1), zt(IdxLocalLzt)];
        LocalBeta = LocalRt\Localzt;
        muPrime_evalpts(1) = LocalBeta(2);
        % Second (Nearest neighbor)
        LocalWt = sqrt(WtVec(IdxLocalHzt));        
        LocalRt = LocalWt.*RtDeriv(IdxLocalHzt);
        Localzt = repmat(LocalWt,[1,2]).*[ones(numel(IdxLocalHzt),1), zt(IdxLocalHzt)];
        LocalBeta = LocalRt\Localzt;
        muPrime_evalpts(2) = LocalBeta(2);
        % Bottom Portfolio
        IdxLocalLportzt = (zt_ind == evalLport);
        LocalWt = sqrt(WtVec(IdxLocalLportzt));                
        LocalRt = LocalWt.*RtDeriv(IdxLocalLportzt);
        Localzt = repmat(LocalWt,[1,2]).*[ones(sum(IdxLocalLportzt),1), zt(IdxLocalLportzt)];
        LocalBeta = LocalRt\Localzt;
        muPrime_evalpts(3) = LocalBeta(2);        
        % Top Portfolio
        IdxLocalHportzt = (zt_ind == evalRport);
        LocalWt = sqrt(WtVec(IdxLocalHportzt));                        
        LocalRt = LocalWt.*RtDeriv(IdxLocalHportzt);
        Localzt = repmat(LocalWt,[1,2]).*[ones(sum(IdxLocalHportzt),1), zt(IdxLocalHportzt)];
        LocalBeta = LocalRt\Localzt;
        muPrime_evalpts(4) = LocalBeta(2);         
    end
end

