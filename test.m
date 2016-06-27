function test( TestDirs, Option )
%TEST runs regression tests for DIMICE.
%   TEST() or TEST('Default') runs the default tests, i.e. all tests in the 
%   Tests directory. All child directories are found recursively.
%
%   TEST(TestDirs) runs the test cases at each directory in TestDirs. This
%   will not look for any child directories.
%
%   TEST('Default', 'Plot') will plot the trajectories
%   during tests.

Tolerance = 1e-8; % Observed errors between 64-Bit Windows and 64-Bit Linux have been as high as 1e-9.
%%
warning('This is not a full regression test. Also run examples.m before sharing.')
addpath('General')
%% Handle inputs.
if ~exist('TestDirs', 'var') || strcmp(TestDirs, 'Default')
    TestRoot = 'Tests';
    fprintf(['Finding all tests in directory ', TestRoot, ' -> '])
    TestDirs = strsplit(genpath(TestRoot), {';',':'});
    TestDirs = TestDirs(~strcmp(TestDirs, TestRoot));
    TestDirs = TestDirs(~strcmp(TestDirs, ''));
    TestDirs = strrep(TestDirs, '\', '/');
    fprintf(['Found ', int2str(length(TestDirs)), '.\n'])
end
if ischar(TestDirs)
    TestDirs = {TestDirs};
end
if exist('Option', 'var')
    if strcmp(Option, 'Plot')
        % This one setting in Config can be overriden, since it should be common to
        % wish to see the test trajectories, though usually this is not necessary.
        PlotTrajectory = true;
    else
        error('Option not recognized.')
    end
else
    PlotTrajectory = false;
end
%%
TestCount = length(TestDirs);
display(['Running ', int2str(TestCount), ' tests:'])
SkipCount = 0;
for i = 1:TestCount
    TestPath = TestDirs{i};
    Config = loadVar([TestPath, '/Config.mat'], 'Config');
    Config.Display.PlotTrajectory = PlotTrajectory;
    fprintf(['\t', int2str(i), '. ' TestPath, ' -> '])
    if ~any(3:6 == exist(Config.NLP.Solver, 'file')) % see "doc exist" for why "3:6" was chosen.
        warning(['Skipping test because ', Config.NLP.Solver,...
            ' is not in path.'])
        SkipCount = SkipCount + 1;
        continue
    end
    Results = dimice(Config);
    if ~exist([TestPath, '/ExpectedResults.mat'], 'file')
        error('This test is missing expected results.')
    end
    ExpectedResults = loadVar([TestPath, '/ExpectedResults.mat'],...
        'Results');
    NormError = norm(Results.X - ExpectedResults.X);
    if NormError > Tolerance
        error(['Test failed: norm error ', sprintf('%g', NormError),...
            ' greater than tolerance ', sprintf('%g', Tolerance)])
    end
    OtherComputer = ExpectedResults.Properties.UserData.Computer;
    % Nullify the UserData to easily compare the numerical results.
    ExpectedResults.Properties.UserData = [];
    Results.Properties.UserData = [];
    if ~isequal(Results, ExpectedResults)
        Message = ['Results are not exactly as expected, ',...
            'but the error norm ', sprintf('%g', NormError),...
            ' is within the tolerance ', sprintf('%g', Tolerance), '.'];
        if ~strcmp(computer, OtherComputer)
            Message = [Message, 'You are using computer ', computer,...
                '; the results were generated with computer ',...
                OtherComputer, '.']; %#ok<AGROW>
        end
        warning(Message)
    end
    fprintf('Success.\n')
end
display(['All tests passed! (Skipped ', int2str(SkipCount), ')'])
end