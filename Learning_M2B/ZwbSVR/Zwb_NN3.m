
% Zwb + SVR 
% features: vgg-face layer 7 (preprocessing: L2 normalization + pca (200 dimensions) )
% normalized labels

% Loading data:
load('initial_data_M2Be_vgg.mat');
devs = 0;
labels = labelsn_e;
X200 = Xpca_7e;

parameters = [1e-09 1e-06 1e-03 1 1e+3 1e+6 1e+9]; 
dims = 10:10:400;


Rate1_euc = zeros(7*7*7, length(dims));
Rate2_euc = zeros(7*7*7, length(dims));
Rate3_euc = zeros(7*7*7, length(dims));
RateTot_euc = zeros(7*7*7, length(dims));

Rate1_cos = zeros(7*7*7, length(dims));
Rate2_cos = zeros(7*7*7, length(dims));
Rate3_cos = zeros(7*7*7, length(dims));
RateTot_cos = zeros(7*7*7, length(dims));


% each row in MAE (RMSE/PC/E) will contain the mean average error
% depending on dim for some fixed values of Alpha, Gamma and Mu

% Option 1: using the Z given by the output of the algorithm
index = 1;
tic;

% Creation of 3 discrete classes: most attractive, average attractiveness, least attractive (intermediate instances are removed to have separate classes)

mean(labels)
% 0.58

display(['Number of images with score over 0.85: ' num2str(sum(labels > 0.85))]);
display(['Number of images with score under 0.3: ' num2str(sum(labels < 0.3))]);
display(['Number of images with score over 0.44 and under 0.72: ' num2str( sum(labels > 0.44 & labels < 0.72) )]);


classes = zeros(length(labels), 1);
classes(labels < 0.3) = 1;
classes(labels > 0.44 & labels < 0.72) = 2;
classes(labels > 0.85) = 3;


labels2 = labels;
labels2(labels >= 0.72 | labels <= 0.44) = 0;

[~, idx] = max(labels2);
classes(idx) = 0;
labels2(idx) = 0;
[~, idx] = max(labels2);
classes(idx) = 0;


mask = classes ~= 0; % mask to remove intermediate instances
X = [X200(:, mask)];
classes = classes(mask);


partition = cvpartition(classes, 'HoldOut', 0.5);
labeled = partition.training;
unlabeled = (labeled == 0);
test = classes(unlabeled);

l = sum(labeled);
u = sum(unlabeled);

% The first columns correspond to labeled instances and the last ones to unlabeled ones
X = [X(:, labeled) X(:, unlabeled)];

% Building the Laplacian matrix (K = 10): 
[~, W]= KNN_GraphConstruction(X, 10);
L = double(diag(sum(W)) - W) ; 


%%
for i = 1:7
    for j = 1:7
        for k = 1:7
            Alpha = parameters(i);            
            Gamma = parameters(j);
            Mu = parameters(k);
            
            % Training the classifier

            % Non-linear transformation:
            [Z, W, b] = ZWb_SemiSupervised(X, classes(labeled), L, Alpha, Gamma, Mu);
            % Z = W'*X200 + b*ones(1, 500); 
            % column representation

            % Z = X200'*W + ones(500, 1) * b';
            % row representation


            for kk = 1:length(dims)


                mdl = fitcknn(Z(labeled, 1:dims(kk)), classes(labeled), 'Distance', 'euclidean', 'NumNeighbors', 1);
                predicted = predict(mdl, Z(labeled, 1:dims(kk)));

                rate1 = sum(predicted == test & test == 1)/sum(test == 1); 
                rate2 = sum(predicted == test & test == 2)/sum(test == 2);
                rate3 = sum(predicted == test & test == 3)/sum(test == 3);
                rateTot = sum(predicted == test)/sum(unlabeled);

                Rate1_euc(index, kk) = rate1;
                Rate2_euc(index, kk) = rate2;
                Rate3_euc(index, kk) = rate3;
                RateTot_euc(index, kk) = rateTot;



                mdl = fitcknn(Z(labeled, 1:dims(kk)), classes(labeled), 'Distance', 'cosine', 'NumNeighbors', 1);
                predicted = predict(mdl, Z(unlabeled, 1:dims(kk)) );

                rate1 = sum(predicted == test & test == 1)/sum(test == 1); 
                rate2 = sum(predicted == test & test == 2)/sum(test == 2);
                rate3 = sum(predicted == test & test == 3)/sum(test == 3);
                rateTot = sum(predicted == test)/sum(unlabeled);

                Rate1_cos(index, kk) = rate1;
                Rate2_cos(index, kk) = rate2;
                Rate3_cos(index, kk) = rate3;
                RateTot_cos(index, kk) = rateTot;


            end


            index = index + 1;
        end
    end
end



save('results_Zwb_3classes_eM2B', 'Rate1_euc', 'Rate2_euc', 'Rate3_euc', 'RateTot_euc', 'Rate1_cos', 'Rate2_cos', 'Rate3_cos', 'RateTot_cos');
toc;



%% Results on Zwb features

load('results_Zwb_3classes_eM2B');


% EUCLIDEAN DISTANCE:
% maximizing rateTot
[rateTot, I] = max(RateTot_euc(:));
[I_row, I_col] = ind2sub(size(RateTot_euc), I);
rateTot

Rate1_euc(I_row, I_col)

Rate2_euc(I_row, I_col)

Rate3_euc(I_row, I_col)
% rateTot = 0.6450
% rate1 = 0.1739
% rate2 = 0.7834
% rate3 = 0.1

% what happens maximizaing rate1
[rate1, I] = max(Rate1_euc(:));
[I_row, I_col] = ind2sub(size(RateTot_euc), I);
rate1

Rate2_euc(I_row, I_col)

Rate3_euc(I_row, I_col)

RateTot_euc(I_row, I_col)


% what happens if we maximize Rate3
[rate3, I] = max(Rate3_euc(:));
[I_row, I_col] = ind2sub(size(RateTot_euc), I);
Rate1_euc(I_row, I_col)
% 
Rate2_euc(I_row, I_col)
% 
rate3
% 
RateTot_euc(I_row, I_col)
% 



% COSINE DISTANCE
% maximizing rateTot
[rateTot, I] = max(RateTot_cos(:));
[I_row, I_col] = ind2sub(size(RateTot_cos), I);
rateTot

Rate1_cos(I_row, I_col)

Rate2_cos(I_row, I_col)

Rate3_cos(I_row, I_col)
% rateTot = 0.7450
% rate1 = 0.0870
% rate2 = 0.9299
% rate3 = 0.05


% what happens if we maximize rate1
[rate1, I] = max(Rate1_cos(:));
[I_row, I_col] = ind2sub(size(RateTot_cos), I);
rate1
Rate2_cos(I_row, I_col)
Rate3_cos(I_row, I_col)





%% Cosas que probablemente no sirvan para nada

dim = dims(I_col);
pp = [];
for i = 1:7
    for j = 1:7
        for k = 1:7
            Alpha = parameters(i);            
            Gamma = parameters(j);
             Mu = parameters(k);
            pp = [pp; Alpha, Gamma, Mu];
        end
    end
end

Alpha = pp(I_row, 1);
Gamma = pp(I_row, 2);
Mu = pp(I_row, 3);

                    				





%% Results with raw features:


% EUCLIDEAN DISTANCE:

mdl = fitcknn((X200(:, labeled))', classes(labeled), 'Distance', 'euclidean', 'NumNeighbors', 1);
predicted = predict(mdl, (X200(:, unlabeled))' );
                    
rate1 = sum(predicted == test & test == 1)/sum(test == 1)
rate2 = sum(predicted == test & test == 2)/sum(test == 2)
rate3 = sum(predicted == test & test == 3)/sum(test == 3)
rateTot = sum(predicted == test)/sum(unlabeled)
% rate1 =  0.0870
% rate2 = 0.7580
% rate3 = 0.1
% rateTot = 0.6150


% COSINE DISTANCE:

mdl = fitcknn((X200(:, labeled))', classes(labeled), 'Distance', 'cosine', 'NumNeighbors', 1);
predicted = predict(mdl, (X200(:, unlabeled))' );
                    
rate1_cos = sum(predicted == test & test == 1)/sum(test == 1) 
rate2_cos = sum(predicted == test & test == 2)/sum(test == 2)
rate3_cos = sum(predicted == test & test == 3)/sum(test == 3)
rateTot_cos = sum(predicted == test)/sum(unlabeled)
% rate1 =  0.0870
% rate2 = 0.7580
% rate3 = 0.1
% rateTot = 0.6150










