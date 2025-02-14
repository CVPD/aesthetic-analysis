% KFME 						
% The Laplacian is based on Gaussian feature similarity only.
% labels are normalized (to lie on the interval (0.2, 1))
% features: vgg-face layer 7 (preprocessing: L2 normalization + pca(200 dimensions) )
% No linear transfom is applied to the scores after KFME.
% Master thesis: Table 3.7 (Output scaling: No).

load('initial_data_SCUT_vgg.mat');
var = devsn.^2;
devs = devsn;
labels = labelsn;
X_n = Xpca_7;



%% 50/50 training/test proportion

epsilon = 0.1; % Remember labels are normalized 0.1 = 0.5/5
parameters_Beta = [0.1 1 10 100 1000 10000];
parameters_Gamma = [1 10 50 100 1000];
parameters_Mu = [0.0001 0.001 0.01 0.1 1 10];
parameters_T0 = [1/8 1/4 1/2 1 2 4 8];

MAE = zeros(10, 6*5*6*7);
PC = zeros(10, 6*5*6*7);
RMSE = zeros(10, 6*5*6*7);
EPSILON = zeros(10, 6*5*6*7);

index = 1;
tic;
for i = 1:length(parameters_Beta)
    for j = 1:length(parameters_Gamma)
        for k = 1:length(parameters_Mu)
            for ii = 1:length(parameters_T0)
                Beta = parameters_Beta(i);
                Gamma = parameters_Gamma(j);
                Mu = parameters_Mu(k);
                T0 = parameters_T0(ii);
                parfor l = 1:10 
                    mask = labeled_masks50(:, l);
                    unlabeled = (mask == 0);
                    [F, Alphas] = KernelFME_Fadi2(X_n, labels, mask, Beta, Gamma, Mu, T0); 
                    %predicted = ((F-min(F))*4/max(F-min(F)) + 1)/5;
                    predicted = F;
                    mae = mean(abs(predicted(unlabeled) - labels(unlabeled)));
                    pc = corr(predicted(unlabeled), labels(unlabeled));
                    rmse = sqrt( mean((predicted(unlabeled) - labels(unlabeled)).^2 ));
                    ee = mean(1 - exp(- (predicted(unlabeled) - labels(unlabeled)).^2/2 ./var(unlabeled) ));
                    MAE(l, index) = mae;
                    PC(l, index) = pc;
                    RMSE(l, index) = rmse;
                    E(l, index) = ee;
                end
                index = index + 1;
            end
        end
    end
end
toc;
% mas o menos 5 horas

save('results_KFME_50knn_vgg7_noLt.mat', 'MAE', 'PC', 'RMSE', 'E');





%% 70/30 training/test proportion

index = 1;
tic;
for i = 1:length(parameters_Beta)
    for j = 1:length(parameters_Gamma)
        for k = 1:length(parameters_Mu)
            for ii = 1:length(parameters_T0)
                Beta = parameters_Beta(i);
                Gamma = parameters_Gamma(j);
                Mu = parameters_Mu(k);
                T0 = parameters_T0(ii);
                parfor l = 1:10
                    mask = labeled_masks70(:, l);
                    unlabeled = (mask == 0);
                    [F, Alphas] = KernelFME_Fadi2(X_n, labels, mask, Beta, Gamma, Mu, T0); 
                    %predicted = ((F-min(F))*4/max(F-min(F)) + 1)/5;
                    predicted = F;
                    mae = mean(abs(predicted(unlabeled) - labels(unlabeled)));
                    pc = corr(predicted(unlabeled), labels(unlabeled));
                    rmse = sqrt( mean((predicted(unlabeled) - labels(unlabeled)).^2 ));
                    ee = mean(1 - exp(- (predicted(unlabeled) - labels(unlabeled)).^2/2 ./var(unlabeled) ));
                    MAE(l, index) = mae;
                    PC(l, index) = pc;
                    RMSE(l, index) = rmse;
                    E(l, index) = ee;
                end
                index = index + 1;
            end
        end
    end
end
toc;


save('results_KFME_70knn_vgg7_noLt.mat', 'MAE', 'PC', 'RMSE', 'E');




%% 90/10 training/test proportion

index = 1;
tic;
for i = 1:length(parameters_Beta)
    for j = 1:length(parameters_Gamma)
        for k = 1:length(parameters_Mu)
            for ii = 1:length(parameters_T0)
                Beta = parameters_Beta(i);
                Gamma = parameters_Gamma(j);
                Mu = parameters_Mu(k);
                T0 = parameters_T0(ii);
                parfor l = 1:10
                    mask = labeled_masks90(:, l);
                    unlabeled = (mask == 0);
                    [F, Alphas] = KernelFME_Fadi2(X_n, labels, mask, Beta, Gamma, Mu, T0); 
                    %predicted = ((F-min(F))*4/max(F-min(F)) + 1)/5;
                    predicted = F;
                    mae = mean(abs(predicted(unlabeled) - labels(unlabeled)));
                    pc = corr(predicted(unlabeled), labels(unlabeled));
                    rmse = sqrt( mean((predicted(unlabeled) - labels(unlabeled)).^2 ));
                    ee = mean(1 - exp(- (predicted(unlabeled) - labels(unlabeled)).^2/2 ./var(unlabeled) ));
                    MAE(l, index) = mae;
                    PC(l, index) = pc;
                    RMSE(l, index) = rmse;
                    E(l, index) = ee;
                end
                index = index + 1;
            end
        end
    end
end
toc;


save('results_KFME_90knn_vgg7_noLt.mat', 'MAE', 'PC', 'RMSE', 'E');



%% Results

load('results_KFME_50knn_vgg7_noLt.mat')
[mae, idx] = min(mean(MAE));
mae
rmse = mean(RMSE(:, idx))
pc = mean(PC(:, idx))
ee = mean(E(:, idx))
% mae = 0.0912
% rmse = 0.1233
% pc = 0.7742
% ee = 0.2284

max(mean(PC))
% 0.8240


load('results_KFME_70knn_vgg7_noLt.mat')
[mae, idx] = min(mean(MAE));
mae
rmse = mean(RMSE(:, idx))
pc = mean(PC(:, idx))
ee = mean(E(:, idx))
% mae = 0.0859
% rmse = 0.1142
% pc = 0.7647
% ee = 0.2159

max(mean(PC))
% 0.8437


load('results_KFME_90knn_vgg7_noLt.mat')
[mae, idx] = min(mean(MAE));
mae
rmse = mean(RMSE(:, idx))
pc = mean(PC(:, idx))
ee = mean(E(:, idx))
% mae = 0.0832
% rmse = 0.1097
% pc = 0.7957
% ee = 0.2121

max(mean(PC))
% 0.8489


%% Best model according to the PC


load('results_KFME_90knn_vgg7_noLt.mat')
[pc, idx] = max(mean(PC))
% pc = 0.8489
% idx = 753

pp = [];
for i = 1:length(parameters_Beta)
    for j = 1:length(parameters_Gamma)
        for k = 1:length(parameters_Mu)
            for ii = 1:length(parameters_T0)
                Beta = parameters_Beta(i);
                Gamma = parameters_Gamma(j);
                Mu = parameters_Mu(k);
                T0 = parameters_T0(ii);
                pp = [pp; Beta Gamma Mu T0];
            end
        end
    end
end

Beta = pp(idx, 1);
Gamma = pp(idx, 2);
Mu = pp(idx, 3);
T0 = pp(idx, 4);

l = 1;
mask = labeled_masks90(:, l);
unlabeled = (mask == 0);
[F, Alphas] = KernelFME_Fadi2(X_n, labels, mask, Beta, Gamma, Mu, T0); 
%predicted = ((F-min(F))*4/max(F-min(F)) + 1)/5;
predicted = F;
pc = corr(predicted(unlabeled), labels(unlabeled))
% 0.8347
% Master thesis: Figure 3.5.
scatter(labels(unlabeled), predicted(unlabeled))
title('Initial predictions of KFME')                    
xlabel('Real labels')
ylabel('Predicted labels')

































