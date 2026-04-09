classdef PolarHeartApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure        matlab.ui.Figure
        UIAxes          matlab.ui.control.UIAxes
        ASliderLabel    matlab.ui.control.Label
        ASlider         matlab.ui.control.Slider
    end

    % App properties
    properties (Access = private)
        Theta           % Theta values for plotting
        PlotHandle      % Handle to the plotted line
        AnimationTimer  % Timer for slow drawing
        CurrentThetaIdx % Current index for animation
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.Theta = linspace(0, 2*pi, 500); % More points for smoother curve
            app.CurrentThetaIdx = 1;
            
            % Initialize plot
            app.UIAxes.XLim = [-2 2];
            app.UIAxes.YLim = [-2 2];
            app.UIAxes.DataAspectRatio = [1 1 1]; % Keep aspect ratio square
            app.UIAxes.Visible = 'off'; % Hide axes for cleaner look
            hold(app.UIAxes, 'on');
            app.PlotHandle = plot(app.UIAxes, NaN, NaN, 'r-', 'LineWidth', 2); % Initialize with NaN
            hold(app.UIAxes, 'off');
            
            % Create and start timer for animation
            app.AnimationTimer = timer('ExecutionMode', 'fixedRate', ...
                                       'Period', 0.01, ... % Adjust speed here
                                       'TimerFcn', @(src, event) app.animatePlot);
            start(app.AnimationTimer);
        end

        % Value changed function: ASlider
        function ASliderValueChanged(app, event)
            % Stop current animation, reset, and restart
            stop(app.AnimationTimer);
            app.CurrentThetaIdx = 1;
            set(app.PlotHandle, 'XData', NaN, 'YData', NaN); % Clear plot
            start(app.AnimationTimer);
        end
        
        % Timer callback function for animation
        function animatePlot(app)
            a = app.ASlider.Value;
            
            % Calculate r for the current theta range
            currentThetaRange = app.Theta(1:app.CurrentThetaIdx);
            r = a * (1 - sin(currentThetaRange));
            
            % Convert polar to Cartesian coordinates
            x = r .* cos(currentThetaRange);
            y = r .* sin(currentThetaRange);
            
            % Update plot data
            set(app.PlotHandle, 'XData', x, 'YData', y);
            
            % Advance index
            app.CurrentThetaIdx = app.CurrentThetaIdx + 1;
            if app.CurrentThetaIdx > length(app.Theta)
                stop(app.AnimationTimer); % Stop when done
                app.CurrentThetaIdx = 1; % Reset for next change
            end
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            % Stop timer before closing app
            if isvalid(app.AnimationTimer)
                stop(app.AnimationTimer);
                delete(app.AnimationTimer);
            end
            delete(app)
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'Polar Heart App';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @app.UIFigureCloseRequest, true);

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, '极坐标心形线: r = a(1 - sin(\theta))')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            app.UIAxes.Position = [100 95 440 350];

            % Create ASliderLabel
            app.ASliderLabel = uilabel(app.UIFigure);
            app.ASliderLabel.HorizontalAlignment = 'right';
            app.ASliderLabel.Position = [100 45 25 22];
            app.ASliderLabel.Text = 'a';

            % Create ASlider
            app.ASlider = uislider(app.UIFigure);
            app.ASlider.Limits = [0.1 2];
            app.ASlider.Value = 1;
            app.ASlider.ValueChangedFcn = createCallbackFcn(app, @app.ASliderValueChanged, true);
            app.ASlider.Position = [140 54 300 3];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = PolarHeartApp

            % Create UIFigure and components
            createComponents(app);

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Destroys the app
        function delete(app)

            % Delete UIFigure when app is destroyed
            delete(app.UIFigure)
        end
    end
end
