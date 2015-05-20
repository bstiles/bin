import scala.dbc._
import scala.dbc.Syntax._
import scala.dbc.syntax.Statement._
import java.net.URI

object HsqldbVendor extends Vendor {
  val uri = new URI("jdbc:hsqldb:hsql://localhost/temp")
  val user = "sa"
  val pass = ""
  
  val retainedConnections = 5
  val nativeDriverClass = Class.forName("org.hsqldb.jdbcDriver")
  val urlProtocolString = "jdbc:hsqldb:"
}

val db = new Database(HsqldbVendor)

val rows = db.executeStatement {
  select fields ("bar" of integer) from ("foo")
}
for (val r <- rows;
     val f <- r.fields) {
  println(f.content.nativeValue) // or .sqlValue
}

db.close


object Foo

def dir(x: AnyRef) = {
  println(x.getClass().getName())
  val objectMethodNames = for (method <- new java.lang.Object().getClass().getMethods()) yield method.getName()
  for (method <- x.getClass().getMethods()
       if java.lang.reflect.Modifier.isPublic(method.getModifiers())
           && ! objectMethodNames.contains(method.getName())) {
    println(method.getName() + method.getParameterTypes().mkString("(", ", ", ")"))
  }
}
dir(Foo)


object Bar {
  val x = 5
  val y = 4
}

object Barf {
  val x = 6
  val y = 4
}

object Baz {
  def foo {
    {
      import Bar.x
      println(x)
    }
    import Barf.x
    println(x)
  }
}
Baz.foo

import Console._

object Foo extends Application{
  def b: Boolean = {
    println("b")
    true
  }
  def f(x: => Boolean) = {
    println("f")
    println(x)
  }
  override def main(args: Array[String]): Unit = {
    def x: Boolean = true
    f(x)
  }
}
Foo.main(Array())
