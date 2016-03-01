classdef ExamplePlugin < plugins.DENSEanalysisPlugin
    % ExamplePlugin - Demonstrates core concepts for  DENSEanalysis plugins

    % This Source Code Form is subject to the terms of the Mozilla Public
    % License, v. 2.0. If a copy of the MPL was not distributed with this
    % file, You can obtain one at http://mozilla.org/MPL/2.0/.
    %
    % Copyright (c) 2016 DENSEanalysis Contributors

    methods
        function validate(~, data)
            % Performs validation to ensure that the state of the program
            % is correct to be able to run the plugin.

            % Assert that data has been loaded
            assert(~isempty(data.seq), ...
                'You must load imaging data into DENSEanalysis first.')
        end

        function run(self, data)
            % Compute statistics on data
            fprintf('Running plugin: %s\n', class(self));
            fprintf('Number of Sequences: %d\n', numel(data.seq));
        end
    end
end
