# Railway-hosted Chainlit app w/ memory 💾


# 1. 💻 run locally
1. install chainlit from my minimal-change fork
```sh
pip install git+https://github.com/guyvandam/chainlit.git#subdirectory=backend/
```
(might need to install `pnpm`)
2. run

 ```chainlit create-secret```
to generate a JWT secret key

3. run the demo app locally
```sh
chainlit run app.py
```
**or**
add this snippet to `app.py` and run 'as usual'
```python
if __name__ == "__main__":
    from chainlit.cli import run_chainlit
    run_chainlit(__file__)
```

# 2. 🚄 deploy w/ memory
1. create a new railway project w/ a postgres DB service
2. create the DB table by setting
```
DATABASE_URL=postgresql://postgres:Uhx...
```
which you can find on the railway variables tab
and run
```sh
npx prisma migrate deploy
```
to create the tables needed for chainlit.
> **note:** run it locally again, your db should be connected
3. deploy to railway
w/ the modified `Dockerfile` from [this](https://railway.com/deploy/atS4DW?referralCode=jk_FgY) template.
The modification is for installing chainlit from my minimal-change fork.
4. add the env variables - make sure to create a reference env variable
`DATABASE_URL` from the DB service `DATABASE_PUBLIC_URL`