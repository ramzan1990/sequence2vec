clear;
clc;

T = readtable('raw-12mer-kd.csv');

total = size(T, 1);
 
fold_size = floor(total / 10);
p = randperm(total);
for fold = 1 : 10
    test_range = (fold - 1) * fold_size + 1 : fold * fold_size;
    train_range = [1 : (fold - 1) * fold_size, fold * fold_size + 1 : total];
     
    fid = fopen(sprintf('10fold_idx/test_idx-%d.txt', fold), 'w');
    for i = 1 : length(test_range)
        fprintf(fid, '%d\n', p(test_range(i)) - 1);
    end
    fclose(fid);

    fid = fopen(sprintf('10fold_idx/train_idx-%d.txt', fold), 'w');
    for i = 1 : length(train_range)
        fprintf(fid, '%d\n', p(train_range(i)) - 1);
    end
    fclose(fid);
end

fid = fopen('12mer-kd.txt', 'w');
fprintf(fid, '%d\n', total);
for i = 1 : total
    fprintf(fid, '%.10f %s\n', T.kd(i), T.str{i});
end
fclose(fid);