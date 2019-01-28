<template>
  <section class="section">
    <div class="container">
      <BField grouped position="is-right">
        <BInput
          v-model="month"
          @keyup.native.enter="getPayroll()"
          placeholder="Enter Month e.g. 1812M"
        ></BInput>
        <p class="control">
          <button @click="getPayroll()" class="button is-primary">Fetch</button>
        </p>
      </BField>
    </div>
    <br>
    <div v-if="view==='daysView'" class="container">
      <table class="table is-striped is-bordered is-hoverable is-narrow">
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th @click="setView('')" class="has-text-centered">Days</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="p in payrollDaysView" :key="p.id">
            <td>
              <span class="white-cell">{{p.id}}</span>
            </td>
            <td>{{p.name}}</td>
            <td class="has-text-centered">{{p.days_worked}}</td>
          </tr>
        </tbody>
        <tfoot>
          <tr>
            <th></th>
            <th></th>
            <th class="has-text-centered">{{ sums.days_worked | currency('')}}</th>
          </tr>
        </tfoot>
      </table>
    </div>
    <div v-if="view==='overtimeView'" class="container">
      <table class="table is-striped is-bordered is-hoverable is-narrow">
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th @click="setView('')" class="has-text-centered">Overtime</th>
            <th @click="setView('')" class="has-text-centered">Overtime Tax</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="p in payrollOvertimeView" :key="p.id">
            <td>
              <span class="white-cell">{{p.id}}</span>
            </td>
            <td>{{p.name}}</td>
            <td class="has-text-right">{{p.overtime_earned}}</td>
            <td class="has-text-right">{{p.overtime_tax}}</td>
          </tr>
        </tbody>
        <tfoot>
          <tr>
            <th></th>
            <th></th>
            <th class="has-text-right">{{ sums.overtime_earned | currency('')}}</th>
            <th class="has-text-right">{{ sums.overtime_tax | currency('')}}</th>
          </tr>
        </tfoot>
      </table>
    </div>
    <div v-if="view==='pfView'" class="container">
      <table class="table is-striped is-bordered is-hoverable is-narrow">
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th class="has-text-centered">Basic Income</th>
            <th @click="setView('')" class="has-text-centered">PF 8%</th>
            <th @click="setView('')" class="has-text-centered">PF 2%</th>
            <th @click="setView('')" class="has-text-centered">Total</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="p in pf.employees" :key="p.id">
            <td>
              <span class="white-cell">{{p.id}}</span>
            </td>
            <td>{{p.name}}</td>
            <td class="has-text-right">{{p.earned_salary | currency('')}}</td>
            <td class="has-text-right">{{p.pf_amount | currency('')}}</td>
            <td class="has-text-right">{{p.pf_employee_contrib | currency('')}}</td>
            <td class="has-text-right">{{p.pf_total_contrib | currency('')}}</td>
          </tr>
        </tbody>
        <tfoot>
          <tr>
            <th></th>
            <th></th>
            <td class="has-text-right">{{ pf.summary.earned_salary | currency('')}}</td>
            <th class="has-text-centered">{{ pf.summary.employer_contrib | currency('')}}</th>
            <th class="has-text-centered">{{ pf.summary.employees_contrib | currency('')}}</th>
            <th class="has-text-centered">{{ pf.summary.total_contrib | currency('')}}</th>
          </tr>
        </tfoot>
      </table>
    </div>
    <div v-if="view==='loansView'" class="container">
      <table class="table is-striped is-bordered is-hoverable is-narrow">
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th @click="setView('')" class="has-text-centered">Loan</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="p in payrollLoansView" :key="p.id">
            <td>
              <span class="white-cell">{{p.id}}</span>
            </td>
            <td>{{p.name}}</td>
            <td class="has-text-right">{{p.loan | currency('')}}</td>
          </tr>
        </tbody>
        <tfoot>
          <tr>
            <th></th>
            <th></th>
            <th class="has-text-right">{{ sums.loan | currency('')}}</th>
          </tr>
        </tfoot>
      </table>
    </div>
    <div v-if="view==='ssnitView'" class="container">
      <table class="table is-striped is-bordered is-hoverable is-narrow">
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th class="has-text-centered">Basic Income</th>
            <th class="has-text-centered">SSNIT #</th>
            <th @click="setView('')" class="has-text-centered">SSNIT (13.0%)</th>
            <th @click="setView('')" class="has-text-centered">SSNIT (5.5%)</th>
            <th @click="setView('')" class="has-text-centered">SSNIT Total</th>
            <th @click="setView('')" class="has-text-centered">SSNIT Tier 1</th>
            <th @click="setView('')" class="has-text-centered">SSNIT Tier 2</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="p in ssnit.employees" :key="p.id">
            <td>
              <span class="white-cell">{{p.id}}</span>
            </td>
            <td>{{p.name}}</td>
            <td class="has-text-right">{{p.earned_salary | currency('')}}</td>
            <td class="has-text-centered">{{p.ssnit_no}}</td>
            <td class="has-text-right">{{p.ssnit_emp_contrib | currency('')}}</td>
            <td class="has-text-right">{{p.ssnit_amount | currency('')}}</td>
            <td class="has-text-right">{{p.ssnit_total_contrib | currency('')}}</td>
            <td class="has-text-right">{{p.ssnit_tier_1 | currency('')}}</td>
            <td class="has-text-right">{{p.ssnit_tier_2 | currency('')}}</td>
          </tr>
        </tbody>
        <tfoot>
          <tr>
            <th></th>
            <th></th>
            <th class="has-text-right">{{ ssnit.summary.earned_salary | currency('')}}</th>
            <th></th>
            <th class="has-text-right">{{ ssnit.summary.employer_contrib | currency('')}}</th>
            <th class="has-text-right">{{ ssnit.summary.employees_contrib | currency('')}}</th>
            <th class="has-text-right">{{ ssnit.summary.total_contrib | currency('')}}</th>
            <th class="has-text-right">{{ ssnit.summary.ssnit_tier_1 | currency('')}}</th>
            <th class="has-text-right">{{ ssnit.summary.ssnit_tier_2 | currency('')}}</th>
          </tr>
        </tfoot>
      </table>
    </div>
    <div v-if="view==='advanceView'" class="container">
      <table class="table is-striped is-bordered is-hoverable is-narrow">
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th @click="setView('')" class="has-text-centered">Advance</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="p in payrollAdvanceView" :key="p.id">
            <td>
              <span class="white-cell">{{p.id}}</span>
            </td>
            <td>{{p.name}}</td>
            <td class="has-text-right">{{p.advance | currency('')}}</td>
          </tr>
        </tbody>
        <tfoot>
          <tr>
            <th></th>
            <th></th>
            <th class="has-text-right">{{ sums.advance | currency('')}}</th>
          </tr>
        </tfoot>
      </table>
    </div>
    <div v-if="view==='pvtLoansView'" class="container">
      <table class="table is-striped is-bordered is-hoverable is-narrow">
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th @click="setView('')" class="has-text-centered">Pvt Loan</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="p in payrollPvtLoansView" :key="p.id">
            <td>
              <span class="white-cell">{{p.id}}</span>
            </td>
            <td>{{p.name}}</td>
            <td class="has-text-right">{{p.pvt_loan | currency('')}}</td>
          </tr>
        </tbody>
        <tfoot>
          <tr>
            <th></th>
            <th></th>
            <th class="has-text-right">{{ sums.pvt_loan | currency('')}}</th>
          </tr>
        </tfoot>
      </table>
    </div>
    <div v-if="view===''" class="container is-fluid">
      <div class="table-responsive">
        <table class="table is-striped is-bordered is-hoverable is-narrow">
          <thead>
            <tr>
              <th>ID</th>
              <th>Name</th>
              <th @click="setView('daysView')" class="has-text-centered">Days</th>
              <th class="has-text-centered">Basic Salary</th>
              <th class="has-text-centered">Earned Salary</th>
              <th @click="setView('ssnitView')" class="has-text-centered">SSNIT</th>
              <th @click="setView('pfView')" class="has-text-centered">PF</th>
              <th class="has-text-centered">Cash Allow.</th>
              <th class="has-text-centered">Total Income</th>
              <th class="has-text-centered">Total Relief</th>
              <th class="has-text-centered">Taxable Income</th>
              <th class="has-text-centered">Tax Ded.</th>
              <th @click="setView('overtimeView')" class="has-text-centered">Overtime</th>
              <th class="has-text-centered">Overtime Tax</th>
              <th class="has-text-centered">Total Tax</th>
              <th class="has-text-centered">TUC Ded.</th>
              <th @click="setView('advanceView')" class="has-text-centered">Advance</th>
              <th @click="setView('loansView')" class="has-text-centered">Loan</th>
              <th class="has-text-centered">Welfare Ded.</th>
              <th @click="setView('pvtLoansView')" class="has-text-centered">Pvt Loan</th>
              <th class="has-text-centered">Total Ded.</th>
              <th class="has-text-centered">Total Pay</th>
              <th class="has-text-centered">Net Pay</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="p in payroll" :key="p.id" :class="[ p.net_pay !== p.total_pay ? 'has-background-warning' : '']">
              <td>
                <span class="white-cell">{{p.id}}</span>
              </td>
              <td>
                <p class="white-cell">{{p.name}}</p>
              </td>
              <td class="has-text-centered">{{p.days_worked}}</td>
              <td class="has-text-right">{{p.base_salary | currency('')}}</td>
              <td class="has-text-right">{{p.earned_salary | currency('')}}</td>
              <td class="has-text-right">{{p.ssnit_amount | currency('')}}</td>
              <td class="has-text-right">{{p.pf_amount | currency('')}}</td>
              <td class="has-text-right">{{p.cash_allowance | currency('')}}</td>
              <td class="has-text-right">{{p.total_cash | currency('')}}</td>
              <td class="has-text-right">{{p.total_relief | currency('')}}</td>
              <td class="has-text-right">{{p.taxable_income | currency('')}}</td>
              <td class="has-text-right">{{p.tax_ded | currency('')}}</td>
              <td class="has-text-right">{{p.overtime_earned | currency('')}}</td>
              <td class="has-text-right">{{p.overtime_tax | currency('')}}</td>
              <td class="has-text-right">{{p.total_tax | currency('')}}</td>
              <td class="has-text-right">{{p.tuc_amount | currency('')}}</td>
              <td class="has-text-right">{{p.advance | currency('')}}</td>
              <td class="has-text-right">{{p.loan | currency('')}}</td>
              <td class="has-text-right">{{p.staff_welfare_ded | currency('')}}</td>
              <td class="has-text-right">{{p.pvt_loan | currency('')}}</td>
              <td class="has-text-right">{{p.total_ded | currency('')}}</td>
              <td class="has-text-right">{{p.total_pay | currency('')}}</td>
              <td class="has-text-right">{{p.net_pay | currency('')}}</td>
            </tr>
          </tbody>
          <tfoot>
            <tr>
              <th></th>
              <th></th>
              <th class="has-text-centered">{{ sums.days_worked | currency('')}}</th>
              <th class="has-text-right">{{sums.base_salary | currency('')}}</th>
              <th class="has-text-right">{{sums.earned_salary | currency('')}}</th>
              <th class="has-text-right">{{sums.ssnit_amount | currency('')}}</th>
              <th class="has-text-right">{{sums.pf_amount | currency('')}}</th>
              <th class="has-text-right">{{sums.cash_allowance | currency('')}}</th>
              <th class="has-text-right">{{sums.total_cash | currency('')}}</th>
              <th class="has-text-right">{{sums.total_relief | currency('')}}</th>
              <th class="has-text-right">{{sums.taxable_income | currency('')}}</th>
              <th class="has-text-right">{{sums.tax_ded | currency('')}}</th>
              <th class="has-text-right">{{sums.overtime_earned | currency('')}}</th>
              <th class="has-text-right">{{sums.overtime_tax | currency('')}}</th>
              <th class="has-text-right">{{sums.total_tax | currency('')}}</th>
              <th class="has-text-right">{{sums.tuc_amount | currency('')}}</th>
              <th class="has-text-right">{{sums.advance | currency('')}}</th>
              <th class="has-text-right">{{sums.loan | currency('')}}</th>
              <th class="has-text-right">{{sums.staff_welfare_ded | currency('')}}</th>
              <th class="has-text-right">{{sums.pvt_loan | currency('')}}</th>
              <th class="has-text-right">{{sums.total_ded | currency('')}}</th>
              <th class="has-text-right">{{sums.total_pay | currency('')}}</th>
              <th class="has-text-right"></th>
            </tr>
          </tfoot>
        </table>
      </div>
    </div>
  </section>
</template>
<script>
import { mapState } from "vuex";

export default {
  payrollDaysView: function() {
    return this.payroll.filter(function(x) {
      return x.days_worked !== "27.00";
    });
  },
  name: "Payroll",
  computed: {
    pf: function() {
      const summary = {
        earned_salary: 0,
        employer_contrib: 0,
        employees_contrib: 0,
        total_contrib: 0
      };
      const employees = [];
      let t_employer_contrib = 0;
      let t_employee_contrib = 0;
      let t_total_contrib = 0;
      this.payroll.forEach(function(x) {
        if (x.pf_amount !== "0.00") {
          t_employer_contrib = Number.parseFloat(x.pf_amount);
          t_employee_contrib = +(
            Math.round(0.25 * t_employer_contrib + "e+2") + "e-2"
          );
          t_total_contrib = t_employer_contrib + t_employee_contrib;

          summary.earned_salary += Number.parseFloat(x.earned_salary);
          summary.employer_contrib += t_employer_contrib;
          summary.employees_contrib += t_employee_contrib;
          summary.total_contrib += t_total_contrib;

          x.pf_employee_contrib = t_employee_contrib;
          x.pf_total_contrib = t_total_contrib;

          employees.push(x);
        }
      });

      return { employees: employees, summary: summary };
    },
    ssnit: function() {
      const summary = {
        earned_salary: 0,
        employer_contrib: 0,
        employees_contrib: 0,
        total_contrib: 0,
        ssnit_tier_1: 0,
        ssnit_tier_2: 0
      };
      const employees = [];
      let t_employer_contrib = 0;
      let t_employee_contrib = 0;
      let t_total_contrib = 0;
      let t_ssnit_tier_1 = 0;
      let t_ssnit_tier_2 = 0;
      this.payroll.forEach(function(x) {
        if (x.ssnit_amount !== "0.00") {
          if (x.id === "E0053") {
            t_employee_contrib = Number.parseFloat(x.ssnit_amount);
            t_employer_contrib = (12.5 / 5) * t_employee_contrib;
            t_total_contrib = t_employer_contrib + t_employee_contrib;
            t_ssnit_tier_1 = t_total_contrib;
            t_ssnit_tier_2 = t_total_contrib - t_ssnit_tier_1;

            summary.earned_salary += Number.parseFloat(x.earned_salary);
            summary.employer_contrib += t_employer_contrib;
            summary.employees_contrib += t_employee_contrib;
            summary.total_contrib += t_total_contrib;
            summary.ssnit_tier_1 += t_ssnit_tier_1;
            summary.ssnit_tier_2 += t_ssnit_tier_2;

            x.ssnit_emp_contrib = t_employer_contrib;
            x.ssnit_total_contrib = t_total_contrib;
            x.ssnit_tier_1 = t_ssnit_tier_1;
            x.ssnit_tier_2 = t_ssnit_tier_2;

            employees.push(x);
          } else {
            t_employee_contrib = Number.parseFloat(x.ssnit_amount);
            t_employer_contrib = Number.parseFloat(
              ((13 / 5.5) * t_employee_contrib).toFixed(2)
            );
            t_total_contrib = t_employer_contrib + t_employee_contrib;
            t_ssnit_tier_1 = Number.parseFloat(
              ((13.5 / 18.5) * t_total_contrib).toFixed(2)
            );
            t_ssnit_tier_2 = t_total_contrib - t_ssnit_tier_1;

            summary.earned_salary += Number.parseFloat(x.earned_salary);
            summary.employer_contrib += t_employer_contrib;
            summary.employees_contrib += t_employee_contrib;
            summary.total_contrib += t_total_contrib;
            summary.ssnit_tier_1 += t_ssnit_tier_1;
            summary.ssnit_tier_2 += t_ssnit_tier_2;

            x.ssnit_emp_contrib = t_employer_contrib;
            x.ssnit_total_contrib = t_total_contrib;
            x.ssnit_tier_1 = t_ssnit_tier_1;
            x.ssnit_tier_2 = t_ssnit_tier_2;

            employees.push(x);
          }
        }
      });

      return { employees: employees, summary: summary };
    },
    sums: function() {
      let data = {
        days_worked: 0,
        base_salary: 0,
        earned_salary: 0,
        ssnit_amount: 0,
        pf_amount: 0,
        cash_allowance: 0,
        total_cash: 0,
        total_relief: 0,
        taxable_income: 0,
        tax_ded: 0,
        overtime_earned: 0,
        overtime_tax: 0,
        total_tax: 0,
        tuc_amount: 0,
        advance: 0,
        loan: 0,
        staff_welfare_ded: 0,
        pvt_loan: 0,
        total_ded: 0,
        total_pay: 0
      };
      this.payroll.forEach(function(x) {
        data.days_worked += Number.parseFloat(x.days_worked);
        data.base_salary += Number.parseFloat(x.base_salary);
        data.earned_salary += Number.parseFloat(x.earned_salary);
        data.ssnit_amount += Number.parseFloat(x.ssnit_amount);
        data.pf_amount += Number.parseFloat(x.pf_amount);
        data.cash_allowance += Number.parseFloat(x.cash_allowance);
        data.total_cash += Number.parseFloat(x.total_cash);
        data.total_relief += Number.parseFloat(x.total_relief);
        data.taxable_income += Number.parseFloat(x.taxable_income);
        data.tax_ded += Number.parseFloat(x.tax_ded);
        data.overtime_earned += Number.parseFloat(x.overtime_earned);
        data.overtime_tax += Number.parseFloat(x.overtime_tax);
        data.total_tax += Number.parseFloat(x.total_tax);
        data.tuc_amount += Number.parseFloat(x.tuc_amount);
        data.advance += Number.parseFloat(x.advance);
        data.loan += Number.parseFloat(x.loan);
        data.staff_welfare_ded += Number.parseFloat(x.staff_welfare_ded);
        data.pvt_loan += Number.parseFloat(x.pvt_loan);
        data.total_ded += Number.parseFloat(x.total_ded);
        data.total_pay += Number.parseFloat(x.total_pay);
      });
      return data;
    },
    payrollDaysView: function() {
      return this.payroll.filter(function(x) {
        return x.days_worked !== "27.00";
      });
    },
    payrollPFView: function() {
      return this.payroll.filter(function(x) {
        return x.pf_amount !== "0.00";
      });
    },
    payrollOvertimeView: function() {
      return this.payroll.filter(function(x) {
        return x.overtime_earned !== "0.00";
      });
    },
    payrollAdvanceView: function() {
      return this.payroll.filter(function(x) {
        return x.advance !== "0.00";
      });
    },
    payrollLoansView: function() {
      return this.payroll.filter(function(x) {
        return x.loan !== "0.00";
      });
    },
    payrollPvtLoansView: function() {
      return this.payroll.filter(function(x) {
        return x.pvt_loan !== "0.00";
      });
    },
    ...mapState(["payroll"])
  },
  methods: {
    getPayroll() {
      this.$store.dispatch("GET_PAYROLL", this.month);
    },
    setView(view) {
      this.view = view;
    }
  },
  data() {
    return {
      month: "",
      view: ""
    };
  }
};
</script>
<style lang="scss" scoped>
div.container {
  padding: 5px;
}
.hidden {
  display: none;
}
.table-responsive {
  overflow: auto;
  height: 80vh;
  > table.table {
    > thead tr th {
      position: sticky;
      top: 0;
      background-color: white;
    }
    > tbody tr td:first-child {
      position: sticky;
      left: 0;
      top: 3em;
      padding: 0;
      > .white-cell {
        display: block;
        background-color: white;
        padding: 0.25em 0.5em;
      }
    }
    > tbody tr td:nth-child(2) {
      position: sticky;
      left: 60px;
      top: 3em;
      padding: 0;
      > .white-cell {
        background-color: white;
        padding: 0.25em 0.5em;
        margin: 0;
      }
    }
  }
}
</style>
