<%@ page language="java" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>
<%@ page language="java"
	import="java.text.*,java.util.Date,java.sql.SQLException,java.sql.DriverManager,java.sql.Connection,java.sql.ResultSet,java.sql.PreparedStatement"%>
<html>

<head>
<%
	//alert(session.getAttribute("SessionID"));
	String id = "";
	id = (String) session.getAttribute("sessionID"); // request에서 id 파라미터를 가져온다
	if (id == null || id.equals("")) { // id가 Null 이거나 없을 경우
		response.sendRedirect("/Subject/user/login.jsp"); // 로그인 페이지로 리다이렉트 한다.
	}
%>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport"
	content="width=device-width, initial-scale=1, shrink-to-fit=no">
<meta name="description" content="">
<meta name="author" content="">

<title>Shoppingbag</title>

<!-- Bootstrap core CSS-->
<link href="vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">

<!-- Custom fonts for this template-->
<link href="vendor/fontawesome-free/css/all.min.css" rel="stylesheet"
	type="text/css">

<!-- Page level plugin CSS-->
<link href="vendor/datatables/dataTables.bootstrap4.css"
	rel="stylesheet">

<!-- Custom styles for this template-->
<link href="css/sb-admin.css" rel="stylesheet">

</head>



<body id="page-top">

	<nav class="navbar navbar-expand navbar-dark bg-dark static-top">

		<a class="navbar-brand mr-1" href="index.jsp"><%=session.getAttribute("sessionID")%>님
			환영합니다</a>

		<button class="btn btn-link btn-sm text-white order-1 order-sm-0"
			id="sidebarToggle" href="#"></button>

		<!-- Navbar Search -->
		<form
			class="d-none d-md-inline-block form-inline ml-auto mr-0 mr-md-3 my-2 my-md-0">

		</form>

		<!-- Navbar -->
		<ul class="navbar-nav ml-auto ml-md-0">

			<li class="nav-item dropdown no-arrow"><a
				class="nav-link dropdown-toggle" href="#" id="userDropdown"
				role="button" data-toggle="dropdown" aria-haspopup="true"
				aria-expanded="false"> <i class="fas fa-user-circle fa-fw"></i>
			</a>
				<div class="dropdown-menu dropdown-menu-right"
					aria-labelledby="userDropdown">
					<a class="dropdown-item" href="/Subject/user/change.jsp">회원정보
						수정</a> <a class="dropdown-item" href="transactions.jsp">구매내역</a>
					<%
						session.getAttribute("sessionID");
					%>
					<div class="dropdown-divider"></div>
					<a class="dropdown-item" href="#" data-toggle="modal"
						data-target="#logoutModal">로그아웃</a>
				</div></li>
		</ul>

	</nav>

	<div id="wrapper">

		<!-- Sidebar -->
		<ul class="sidebar navbar-nav">
			<li class="nav-item active"><a class="nav-link" href="index.jsp">
					<i class="fas fa-fw fa-tachometer-alt"></i> <span>상품추천&카테고리</span>
			</a></li>
			<li class="nav-item"><a class="nav-link" href="shoppingbag.jsp">
					<i class="fas fa-fw fa-folder"></i> <span>장바구니</span>
			</a></li>

			<li class="nav-item"><a class="nav-link" href="tables.jsp">
					<i class="fas fa-fw fa-table"></i> <span>상품 목록</span>
			</a></li>
		</ul>

		<div id="content-wrapper">

			<div class="container-fluid">

				<!-- DataTables Example -->
				<div class="card mb-3">
					<div class="card-header">
						<i class="fas fa-table"></i> 구매내역
					</div>
					<div class="card-body">
						<div class="table-responsive">
							<table class="table table-bordered" id="dataTable" width="100%"
								cellspacing="0">
								<%
									String serverIP = "localhost";
									String portNum = "3306";
									String url = "jdbc:mysql://" + serverIP + ":" + portNum + "/dbpro?useSSL=false";
									String user = "knu";
									String pass = "comp322";
									Connection conn = null;
									PreparedStatement pstmt = null;
									ResultSet rs;
									Class.forName("com.mysql.jdbc.Driver");
									conn = DriverManager.getConnection(url, user, pass);
									try {
										Class.forName("com.mysql.jdbc.Driver");//JDBC_DRIVER); 
										//Class 클래스의 forName()함수를 이용해서 해당 클래스를 메모리로 로드 하는 것입니다.
										//URL, ID, password를 입력하여 데이터베이스에 접속합니다.
										conn = DriverManager.getConnection(url, user, pass);
										conn.setAutoCommit(false);
										conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
										String query = "";

										String buy = (request.getParameter("buy") == null) ? "" : request.getParameter("buy");

										if (!buy.equals("")) {
											pstmt = conn.prepareStatement("SELECT S.Transaction_number, IC.Product_number, IC.Ordered_amount "
													+ "FROM SHOPPINGBAG S, INCLUDE IC " + "WHERE S.Id = ? "
													+ "AND S.Transaction_number = IC.Transaction_number " + " AND S.Paydate IS NULL");
											pstmt.setString(1, id);

											rs = pstmt.executeQuery();
											//conn.commit();

											String transaction_number = (rs.next() == false) ? "" : rs.getString(1);
											System.out.println(rs.getString(3));
											System.out.println(rs.getString(2));
											rs.beforeFirst();

											pstmt = conn.prepareStatement("update ITEM set Item_amount=Item_amount-? WHERE Product_number=? ");
											while (rs.next()) {
												System.out.println(rs.getString(3));
												System.out.println(rs.getString(2));
												pstmt.setString(1, rs.getString(3));
												pstmt.setString(2, rs.getString(2));
												pstmt.executeUpdate();
											}

											Date today = new Date();
											SimpleDateFormat time = new SimpleDateFormat("yyyy-MM-dd");
											String paydate = time.format(today);
											System.out.println(paydate);
											//String paydate = "2018-12-01";

											pstmt = conn.prepareStatement("update SHOPPINGBAG set Paydate=? WHERE Transaction_number=?");
											pstmt.setString(1, paydate);
											pstmt.setString(2, transaction_number);
											pstmt.executeUpdate();

											pstmt = conn.prepareStatement("SELECT COUNT(S.Transaction_number) FROM SHOPPINGBAG S ");
											rs = pstmt.executeQuery();
											if (rs.next()) {
												pstmt = conn.prepareStatement(
														"insert into SHOPPINGBAG (Transaction_number, Paydate,Id) values (?,NULL,?)");
												pstmt.setString(1, "T" + (Integer.parseInt(rs.getString(1)) + 1));
												pstmt.setString(2, id);
												pstmt.executeUpdate();
											}
										}
										conn.commit();
									} catch (ClassNotFoundException | SQLException sqle) {
										// 오류시 롤백
										conn.rollback();
										out.println(
												"<script type=\"text/javascript\">alert(\"구매 실패 - 재고 등을 문의해주세요\");location.href = \"./shoppingbag.jsp\";</script>");
									} finally {
										// Connection, PreparedStatement를 닫는다.
										try {
											if (pstmt != null) {
												pstmt.close();
												pstmt = null;
											}
											if (conn != null) {
												conn.close();
												conn = null;
											}
										} catch (Exception e) {
											throw new RuntimeException(e.getMessage());
										}
									}
								%>
								<thead>
									<tr>
										<th>거래번호</th>
										<th>거래일</th>
										<th>물품코드</th>
										<th>물품명</th>
										<th>물품가격</th>
										<th>주문수</th>
										<th>구매액</th>
									</tr>
								</thead>
								<%
									try {
										Class.forName("com.mysql.jdbc.Driver");//JDBC_DRIVER); 
										//Class 클래스의 forName()함수를 이용해서 해당 클래스를 메모리로 로드 하는 것입니다.
										//URL, ID, password를 입력하여 데이터베이스에 접속합니다.
										conn = DriverManager.getConnection(url, user, pass);
										conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
										conn.setAutoCommit(false);
										String query = "";

										query = "SELECT IC.Transaction_number, S.Paydate, IC.Product_number, IT.Item_name, IT.Item_price, IC.Ordered_amount, SUM(IC.Ordered_amount)*IT.Item_price "
												+ "FROM INCLUDE IC, ITEM IT, SHOPPINGBAG S   "
												+ "WHERE S.Transaction_number = IC.Transaction_number " + "AND S.Paydate IS NOT NULL   "
												+ "AND S.Id = ?  " + "AND IC.Product_number = IT.Product_number "
												+ "GROUP BY  IC.Transaction_number, IC.Product_number, IT.Item_name, IC.Ordered_amount, IT.Item_price "
												+ "ORDER BY Paydate asc";
										pstmt = conn.prepareStatement(query);
										if (!id.equals(""))
											pstmt.setString(1, id);
										rs = pstmt.executeQuery();

										//out.println():print out given text to the current HTML doucment.

										//ResultSetMetaData rsmd = rs.getMetaData();
										//int cnt = rsmd.getColumnCount();
										out.println("<tbody>");
										while (rs.next()) {
											out.println("<tr>");
											out.println("<td>" + rs.getString(1) + "</td>");
											out.println("<td>" + rs.getString(2) + "</td>");
											out.println("<td>" + rs.getString(3) + "</td>");
											out.println("<td>" + rs.getString(4) + "</td>");
											out.println("<td>" + rs.getString(5) + "</td>");
											out.println("<td>" + rs.getString(6) + "</td>");
											out.println("<td>" + rs.getString(7) + "</td>");
											//수정 버튼

											out.println("</tr>");
										}
										out.println("</tbody>");
										pstmt.executeQuery();
										conn.commit();
									} catch (ClassNotFoundException | SQLException sqle) {
										// 오류시 롤백
										conn.rollback();

										throw new RuntimeException(sqle.getMessage());
									} finally {
										// Connection, PreparedStatement를 닫는다.
										try {
											if (pstmt != null) {
												pstmt.close();
												pstmt = null;
											}
											if (conn != null) {
												conn.close();
												conn = null;
											}
										} catch (Exception e) {
											throw new RuntimeException(e.getMessage());
										}
									}
								%>


							</table>
						</div>
					</div>
					<div class="card-footer small text-muted">Updated yesterday
						at 11:59 PM</div>
				</div>

				<p class="small text-center text-muted my-5">
					<em>More table examples coming soon...</em>
				</p>

			</div>
			<!-- /.container-fluid -->



		</div>
		<!-- /.content-wrapper -->

	</div>
	<!-- /#wrapper -->

	<!-- Scroll to Top Button-->
	<a class="scroll-to-top rounded" href="#page-top"> <i
		class="fas fa-angle-up"></i>
	</a>

	<!-- Logout Modal-->
	<div class="modal fade" id="logoutModal" tabindex="-1" role="dialog"
		aria-labelledby="exampleModalLabel" aria-hidden="true">
		<div class="modal-dialog" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="exampleModalLabel">Ready to Leave?</h5>
					<button class="close" type="button" data-dismiss="modal"
						aria-label="Close">
						<span aria-hidden="true">로그아웃</span>
					</button>
				</div>
				<div class="modal-body">Select "Logout" below if you are ready
					to end your current session.</div>
				<div class="modal-footer">
					<button class="btn btn-secondary" type="button"
						data-dismiss="modal">Cancel</button>
					<a class="btn btn-primary" href="/Subject/user/login.jsp">Logout</a>
				</div>
			</div>
		</div>
	</div>

	<!-- Bootstrap core JavaScript-->
	<script src="vendor/jquery/jquery.min.js"></script>
	<script src="vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

	<!-- Core plugin JavaScript-->
	<script src="vendor/jquery-easing/jquery.easing.min.js"></script>

	<!-- Page level plugin JavaScript-->
	<script src="vendor/datatables/jquery.dataTables.js"></script>
	<script src="vendor/datatables/dataTables.bootstrap4.js"></script>

	<!-- Custom scripts for all pages-->
	<script src="js/sb-admin.min.js"></script>

	<!-- Demo scripts for this page-->
	<script src="js/demo/datatables-demo.js"></script>

</body>

</html>
