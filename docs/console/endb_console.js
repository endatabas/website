var Module = {
    print: (...text) => {
        const outputElement = document.getElementById("output");
        const footerElement = document.getElementById("footer");
        text = text.join(" ");
        console.log(text);

        if (outputElement) {
            const div = document.createElement("div");
            div.innerText = text;
            outputElement.appendChild(div);
            footerElement.scrollIntoView({block: "nearest"});
        }
    },
    canvas: {
        addEventListener: () => {},
        getBoundingClientRect: () => ({ bottom: 0, height: 0, left: 0, right: 0, top: 0, width: 0 }),
    },
    onCustomMessage: (e) => {
        if (e.data.userData.id === "postRun") {
            Module.postRun();
        }
    },
    setStatus: (text) => {
        const statusElement = document.getElementById("status");
        statusElement.innerHTML = text;
    },
    postRun: () => {
        const spinnerElement = document.getElementById("spinner");
        const inputElement = document.getElementById("input");
        const outputElement = document.getElementById("output");
        const footerElement = document.getElementById("footer");

        spinnerElement.style.display = "none";
        inputElement.style.display = "block";

        const callbacks = {};

        Module.onCustomMessage = (e) => {
            const id = e.data.userData.id;
            const cb = callbacks[id];
            delete callbacks[id];
            if (cb) {
                cb(e.data.userData);
            }
        };

        let id = 0;
        function send(method, params, cb) {
            id++;
            callbacks[id.toString()] = cb;
            const message = {id: id.toString(), method, params};
            window.postCustomMessage(message);
        }

        send("common_lisp_eval", [`
(progn
  (endb/lib:log-info "version ~A" (endb/lib:get-endb-version))
  (endb/lib:log-info "data directory :memory:")
  (defvar *db* (endb/sql:make-db)))`],
             () => {
                 console.log("running on https://ecl.common-lisp.dev/ powered by https://emscripten.org/")
                 const div = document.createElement("div");
                 div.innerHTML = "running on <a href=\"https://ecl.common-lisp.dev/\" target=\"_top\">https://ecl.common-lisp.dev/</a> powered by <a href=\"https://emscripten.org/\" target=\"_top\">https://emscripten.org/</a>";
                 outputElement.appendChild(div);

                 Module.print("print :help for help.\n\n");
             });

        function executeSQL(sql) {
            send("common_lisp_eval",[`
(let ((endb/json:*json-ld-scalars* nil))
  (endb/json:json-stringify
    (handler-case
        (let ((write-db (endb/sql:begin-write-tx *db*)))
          (multiple-value-bind (result result-code)
              (endb/sql:execute-sql write-db (endb/json:json-parse ${JSON.stringify(JSON.stringify(sql))}))
            (setf *db* (endb/sql:commit-write-tx *db* write-db))
            (fset:map ("result" result) ("resultCode" result-code))))
      (error (e)
        (fset:map ("error" (format nil "~A" e)))))))`],
                 (e) => {
                     let {result, resultCode, error} = JSON.parse(JSON.parse(e.result));
                     if (error) {
                         Module.print(error);
                     } else {
                         if (!Array.isArray(resultCode)) {
                             result = [[resultCode]];
                             resultCode = ["result"];
                         }

                         console.log(resultCode.join("\t\t"));
                         result.forEach((row) => {
                             console.log(row.map((col) => JSON.stringify(col)).join("\t\t"));
                         });

                         const thead = "<thead><tr>" + resultCode.map((col) => "<th>" + col + "</th>").join("") + "</tr></thead>";
                         const tbody = "<tbody>" + result.map((row) => {
                             return "<tr>" + row.map((col) => "<td>" + JSON.stringify(col) + "</td>").join("") + "</tr>";
                         }).join("") + "</tbody>";

                         const table = document.createElement("table");
                         table.innerHTML = thead + tbody;
                         outputElement.appendChild(table);
                     }
                     Module.print("\n");
                 });
        }

        function resizeInput() {
            inputElement.style.height = "";
            inputElement.style.height = inputElement.scrollHeight +"px"
            footerElement.scrollIntoView({block: "nearest"});
        }

        window.addEventListener("resize", () => {
            resizeInput();
        });
        inputElement.addEventListener("input", () => {
            resizeInput();
        });
        inputElement.addEventListener("change", () => {
            resizeInput();
        });

        let commandHistory = [];
        let commandHistoryIndex = -1;

        function addToHistory(command) {
            if (commandHistory[commandHistory.length - 1] !== command) {
                commandHistory.push(command);
            }
            commandHistoryIndex = commandHistory.length;
        }

        function resetInput(text) {
            inputElement.value = text;
            resizeInput();
        }

        inputElement.addEventListener("keydown", (e) => {
            if (e.keyCode == 13 && inputElement.value.trim().startsWith(":")) {
                let command = inputElement.value;
                addToHistory(command);
                resetInput("");
                Module.print(command);
                command = command.trim();
                if (command === ":help") {
                    Module.print("key bindings:\nC-a\tbeginning of line\nC-e\tend of line\nC-RET\tevaluate\nM-p\tprevious history\nM-n\tnext history\n\n");
                } else {
                    Module.print(`unknown command ${command}\n\n`);
                }
                e.preventDefault();
            } else if (e.keyCode == 13 && (e.ctrlKey || inputElement.value.trim().endsWith(";"))) {
                const sql = inputElement.value;
                addToHistory(sql);
                resetInput("");
                Module.print(sql);
                executeSQL(sql);
                e.preventDefault();
            } else if (e.ctrlKey) {
                if (e.keyCode == 65) {
                    inputElement.setSelectionRange(0, 0);
                    e.preventDefault();
                } else if (e.keyCode == 69) {
                    const end = inputElement.value.length;
                    inputElement.setSelectionRange(end, end);
                    e.preventDefault();
                }
            } else if (e.altKey) {
                if (e.keyCode == 78) {
                    if (commandHistoryIndex < commandHistory.length + 1) {
                        commandHistoryIndex++;
                        resetInput(commandHistory[commandHistoryIndex] ?? "");
                    }
                    e.preventDefault();
                } else if (e.keyCode == 80) {
                    if (commandHistoryIndex > 0) {
                        commandHistoryIndex--;
                        resetInput(commandHistory[commandHistoryIndex] ?? "");
                    }
                    e.preventDefault();
                }
            }
        });
        setTimeout(() => inputElement.focus(), 0);
    },
};

window.addEventListener("error", () => {
    const statusElement = document.getElementById("status");
    const spinnerElement = document.getElementById("spinner");
    Module.setStatus("Exception thrown, see JavaScript console");
    statusElement.style.display = "block";
    spinnerElement.style.display = "none";
    Module.setStatus = (text) => {
        if (text) {
            console.error("[post-exception status]", text);
        }
    };
});

{
    // Disable forwarding of key events to worker in
    // https://github.com/emscripten-core/emscripten/blob/main/src/proxyClient.js
    const realAddEventListener = document.addEventListener;
    document.addEventListener = (event) => {
        if (event === "visibilitychange") {
            document.addEventListener = realAddEventListener;
        }
    }
}
