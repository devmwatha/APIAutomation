import uvicorn
from fastapi import FastAPI, Request
from pydantic import BaseModel
import time

app = FastAPI()


class Post(BaseModel):
    response: str


# async
@app.post("/callback")
def root(request: Request):
    # print("I am here")
    time.sleep(5)
    print(request.body().__str__())


if __name__ == "__main__":
    uvicorn.run(app, host="172.31.235.238", port=8080)
