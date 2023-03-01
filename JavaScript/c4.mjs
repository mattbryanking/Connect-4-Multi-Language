import { exit } from "process";       
import Connect4 from "./Connect4.mjs"  

const myArgs = process.argv.slice(2);

let rows = 6;
let cols = 7;
let winLength = 4;


if (myArgs.length >= 1) {
    let matches = /(\d+)x(\d+)/.exec(myArgs[0]);
    if (matches === null) {
        console.log(`Board size "${myArgs[0]}" is not formatted properly.`);
        exit(); 
    } else {
        // matches are strings
        rows = parseInt(matches[1]);
        cols = parseInt(matches[2]);
        winLength = process.argv[3];
    }
}

(new Connect4(rows, cols, winLength)).playGame(1, 0, () => {});
