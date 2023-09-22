
let Metric = 0;


function Tick(Metric)
{
        document.getElementById("Metric").innerHTML = `You are visitor number: ${Metric}`;
}

fetch("https://32jb3yglih.execute-api.ap-southeast-2.amazonaws.com/test/{proxy+}")
        .then((Response) => Response.json())
        .then((RetVal) => {
                Metric = RetVal
                Tick(Metric);
        });