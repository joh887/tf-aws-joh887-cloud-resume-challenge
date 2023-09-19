
let Metric = 0;


function Tick(Metric)
{
        document.getElementById("Metric").innerHTML = `You are visitor number: ${Metric}`;
}

fetch("https://k7qhpi7pcn4ieiat7js655fkgy0zraez.lambda-url.ap-southeast-2.on.aws/")
        .then((Response) => Response.json())
        .then((RetVal) => {
                Metric = RetVal
                Tick(Metric);
        });