
!%comspec% /c ""C:\ProgramData\Anaconda3\Scripts\activate.bat" "C:\ProgramData\Anaconda3\envs\brainglobe""
%     !%comspec% /c ""C:\ProgramData\Anaconda3\Scripts\activate.bat" "C:\ProgramData\Anaconda3\envs\dlc""

[VERSION, EXECUTABLE, ISLOADED] = pyversion;
%     if ~ISLOADED && ~strcmp(EXECUTABLE,'C:\ProgramData\Anaconda3\envs\DEEPLABCUT\python.exe')
%         [VERSION, EXECUTABLE, ISLOADED] = pyversion('C:\ProgramData\Anaconda3\envs\DEEPLABCUT\python.exe');
%     end
if ~ISLOADED && ~strcmp(EXECUTABLE,'C:\ProgramData\Anaconda3\envs\brainglobe\python.exe')
    [VERSION, EXECUTABLE, ISLOADED] = pyversion('C:\ProgramData\Anaconda3\envs\brainglobe\python.exe');
end

add2Path = {'C:\ProgramData\Anaconda3\brainglobe\Deeplabcut',...
            'C:\ProgramData\Anaconda3\Library\mingw-w64\bin',...
            'C:\ProgramData\Anaconda3\Library\usr\bin',...
            'C:\ProgramData\Anaconda3\envs\brainglobe\Library\bin',...
            'C:\ProgramData\Anaconda3\envs\brainglobe\Scripts'};

ENV = getenv('PATH');
ENV = strsplit(ENV, ';');
ENV = [add2Path(:); ENV(:)];
ENV = unique(ENV, 'stable');
ENV = strjoin(ENV, ';');
setenv('PATH', ENV);
% clear classes

module_to_load = 'brainglobe_atlasapi';
python_module_to_use = py.importlib.import_module(module_to_load);
py.importlib.reload(python_module_to_use);
% Now you can use it like output = py.some_awesome_python_module.some_awesome_python_function(input)
 