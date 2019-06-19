<template>
  <section class="hero is-success is-fullheight">
    <div class="hero-body">
      <div class="container has-text-centered">
        <div class="column is-4 is-offset-4">
          <!--<h3 class="title has-text-grey">Login</h3>-->
          <!--<p class="subtitle has-text-grey">Please login to proceed.</p>-->
          <div class="box">
            <figure class="avatar">
              <img src="../assets/mgp.png" />
            </figure>
            <form>
              <div class="field">
                <div class="control">
                  <input
                    v-model="form.username"
                    class="input is-large"
                    required
                    type="text"
                    placeholder="Your Username"
                    autofocus=""
                    :class="{ 'is-danger': error.username }"
                  />
                </div>
              </div>

              <div class="field">
                <div class="control">
                  <input
                    v-model="form.password"
                    class="input is-large"
                    required
                    type="password"
                    placeholder="Your Password"
                    :class="{ 'is-danger': error.password }"
                  />
                </div>
              </div>
              <!--<div class="field">-->
              <!--<label class="checkbox">-->
              <!--<input type="checkbox">-->
              <!--Remember me-->
              <!--</label>-->
              <!--</div>-->
              <button
                @click.prevent="tryLogin"
                class="button is-block is-danger is-outlined is-large is-fullwidth"
              >
                Login
              </button>
            </form>
          </div>
          <!--<p class="has-text-grey">-->
          <!--<a href="../">Sign Up</a> &nbsp;·&nbsp;-->
          <!--<a href="../">Forgot Password</a> &nbsp;·&nbsp;-->
          <!--<a href="../">Need Help?</a>-->
          <!--</p>-->
        </div>
      </div>
    </div>
  </section>
</template>

<script>
export default {
  name: "Login",
  data() {
    return {
      form: {
        username: "",
        password: ""
      },
      error: {
        username: false,
        password: false
      }
    };
  },
  methods: {
    tryLogin() {
      this.resetErrors();

      if (this.form.username !== "hvaria") return (this.error.username = true);
      if (this.form.password !== "password")
        return (this.error.password = true);

      this.resetErrors();

      this.$router.push("home");
    },
    resetErrors() {
      this.error.username = false;
      this.error.password = false;
    }
  }
};
</script>

<style scoped>
.hero.is-success {
  background: #f2f6fa;
}
.hero .nav,
.hero.is-success .nav {
  -webkit-box-shadow: none;
  box-shadow: none;
}
.box {
  margin-top: 5rem;
}
.avatar {
  margin-top: -70px;
  padding-bottom: 20px;
}
.avatar img {
  padding: 5px;
  background: #fff;
  /*border-radius: 50%;*/
  -webkit-box-shadow: 0 2px 3px rgba(10, 10, 10, 0.1),
    0 0 0 1px rgba(10, 10, 10, 0.1);
  box-shadow: 0 2px 3px rgba(10, 10, 10, 0.1), 0 0 0 1px rgba(10, 10, 10, 0.1);
}
input {
  font-weight: 300;
}
p {
  font-weight: 700;
}
p.subtitle {
  padding-top: 1rem;
}
</style>
