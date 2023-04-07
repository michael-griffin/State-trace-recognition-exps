%Kill key script, ends experiment and saves data
qKey = KbName('q');
% while KbCheck end;
% [keyIsDown, seconds, keyCode] = KbCheck;

% while keyIsDown
    if keyIsDown
        if keyCode(qKey)
            sca;
            commandwindow;
            break;
        end
    end
% end
